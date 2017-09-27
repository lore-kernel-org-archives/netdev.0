From: Markus Heiser <markus.heiser@darmarit.de>
Subject: Re: [PATCH net-next 2/2] tools: bpf: add bpftool
Date: Wed, 27 Sep 2017 13:49:58 +0200
Message-ID: <C92884FB-9948-4CCF-9B58-7811691F6574@darmarit.de>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
 <20170926153522.31500-3-jakub.kicinski@netronome.com>
 <20170926222405.nq23enzudbjklczb@ast-mbp> <20170927000208.4396dfb7@cakuba>
 <20170927124511.650870bc@redhat.com> <20170927035742.5c9ee8c3@cakuba>
 <20170927131906.286b1e25@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com,
        Linux Doc Mailing List <linux-doc@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Jonathan Corbet <corbet@lwn.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170927131906.286b1e25@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Am 27.09.2017 um 13:19 schrieb Jesper Dangaard Brouer <brouer@redhat.com>:
[...]
>>> I would prefer adding a README.rst file, in RST-format, as the rest of
>>> the kernel documentation is moving in that direction[1] (your github
>>> version is in README.md format).  A man page will always be
>>> out-of-sync, and even out-of-sync on different distros.
>>> 
>>> See[1]: https://www.kernel.org/doc/html/latest/
>>> 
>>> And then I would find some place in Documentation/admin-guide/ and
>>> include the README.rst file, so it shows up at [1].
>>> 
>>> RST have an include method like:
>>> 
>>> .. include:: ../../tools/bpf/bpftool/README.rst  
>> 
>> Can the docs in new format be rendered into a man page?  Call me old
>> fashioned but I think we should provide some form of a man page.. :)
> 
> Yes, simply create the man page like:
> 
> rst2man README.rst README.man
> You can add this to your local makefile.

Hm ... this will work only for simple reST files.

FYI: Sphinx is build up on top of docutils extending the reST markup. Tools
like rst2man are from docutils and do not cover the markup extensions
from Sphinx. Since Sphinx has its own builder for man pages, generating
man pages is not the problem ...

> The standard sphinx build can also generate man-pages, but it have been
> removed from the kernel makefile targets:
> 
> Documentation targets:
> Linux kernel internal documentation in different formats from ReST:
> htmldocs        - HTML
> latexdocs       - LaTeX
> pdfdocs         - PDF
> epubdocs        - EPUB
> xmldocs         - XML
> linkcheckdocs   - check for broken external links (will connect to external hosts)
> cleandocs       - clean all generated files

The reason why we have no man page target is, that we have not yet
evaluated a concept, how we can manage the 'build man pages' task in
the kernel build.

Beside what you find in the kernel-source tree I'am working on such
a concept (adapted man page builder for the Kernel) [1].

IMO: Even if we merge the builder from [1] or implement something different,
we have to touch the current kernel-doc parser. I guess that and the absence
of a handy concept is the reason why we are dangling with a 'man' target.

Anyway, these are my estimations, it might be better if we hear what
Jon think about a man page builder (concept).

[1] https://return42.github.io/linuxdoc/linuxdoc-howto/man-pages.html

-- Markus --

