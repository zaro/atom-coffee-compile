CoffeeCompileView = require '../lib/coffee-compile-view'
{WorkspaceView} = require 'atom'
fs = require 'fs'

describe "CoffeeCompileView", ->
  compiled = null
  editor   = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    atom.workspace     = atom.workspaceView.model

    waitsForPromise ->
      atom.project.open('test.coffee').then (o) ->
        editor = o

    waitsForPromise ->
      atom.packages.activatePackage('language-coffee-script')

  describe "renderCompiled", ->
    beforeEach ->
      runs ->
        compiled = new CoffeeCompileView {sourceEditor: editor}

    it "should compile the whole file and display compiled js", ->
      spyOn compiled, "renderCompiled"

      runs ->
        compiled.renderCompiled()

      waitsFor "Coffeescript should be compiled", ->
        compiled.renderCompiled.callCount > 0

      runs ->
        expect(compiled.scrollView).toExist()

  describe "saveCompiled", ->
    filePath = null
    beforeEach ->
      filePath = editor.getPath()
      filePath = filePath.replace ".coffee", ".js"

      atom.config.set 'coffee-compile.compileOnSave', true

      compiled = new CoffeeCompileView {sourceEditor: editor}

    afterEach ->
      fs.unlink(filePath) if fs.existsSync(filePath)

      coffeeFilePath = editor.getPath()
      fs.unlink(coffeeFilePath) if fs.existsSync(coffeeFilePath)

    it "should compile and create a js when saving", ->
      spyOn compiled, "saveCompiled"

      editor.save()

      expect(compiled.saveCompiled).toHaveBeenCalled()

    it "should compile and create a js file", ->
      callback = jasmine.createSpy 'save'

      runs ->
        compiled.saveCompiled callback

      waitsFor "Compile on save", ->
        callback.callCount > 0

      runs ->
        expect(fs.existsSync(filePath)).toBeTruthy()
