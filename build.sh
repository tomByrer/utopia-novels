#!/bin/bash

# Expects a local pandoc installation
pandoc=`which pandoc`
readme="README.md"
tmp=".tmp.md" # Temporary metadata for autogenerated README output

if [ ! -f "$pandoc" ]; then echo "Please install pandoc from https://pandoc.org/"; exit; fi

# Automatically generate the top-level README based on introspection
cat > $readme <<END
# 19th century utopian novels by women
A small collection of 19th/20th century utopian fiction.

This collection was part of the research material for the interactive fiction story, [Harmonia](https://github.com/lizadaly/harmonia).

Contributions, corrections, and proofed new editions are very welcome; please issue a <a href="https://opensource.guide/how-to-contribute/">pull request</a>. 

The current collection:
END

for dir in books/*
  do
    book="$(basename "$dir")"

    echo "Generating HTML, EPUB, and README files for $book as $dir/$book.html"

    # Generate HTML version with appropriate paths
    $pandoc  -o $dir/$book.html $dir/book.md  --css ../../shared/web.css \
      --template shared/html-template.html --resource-path $dir:shared

    # Generate EPUB
    $pandoc -o $dir/$book.epub $dir/book.md --epub-embed-font=shared/fonts/* \
      --css shared/epub.css --template shared/epub-template.html --epub-cover-image $dir/cover.png

    # Generate per-book README
    $pandoc -o $dir/README.md -V book=$book $dir/book.md --template shared/readme-template.md

    # Build up the main project README with a dynamic book list
    $pandoc  -o $tmp $dir/book.md -V book=$book -V dir=$dir --template shared/metadata-template.md
    cat $tmp >> $readme
    rm $tmp

  done
