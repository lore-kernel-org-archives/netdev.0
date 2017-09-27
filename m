From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 2/2] tools: bpf: add bpftool
Date: Wed, 27 Sep 2017 12:45:11 +0200
Message-ID: <20170927124511.650870bc@redhat.com>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
        <20170926153522.31500-3-jakub.kicinski@netronome.com>
        <20170926222405.nq23enzudbjklczb@ast-mbp>
        <20170927000208.4396dfb7@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170927000208.4396dfb7@cakuba>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Sep 2017 00:02:08 +0100
Jakub Kicinski <jakub.kicinski@netronome.com> wrote:

> On Tue, 26 Sep 2017 15:24:06 -0700, Alexei Starovoitov wrote:
> > On Tue, Sep 26, 2017 at 08:35:22AM -0700, Jakub Kicinski wrote:  
> > > Add a simple tool for querying and updating BPF objects on the system.
> > > 
> > > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > > Reviewed-by: Simon Horman <simon.horman@netronome.com>
[...]
> > >  tools/bpf/Makefile             |  18 +-
> > >  tools/bpf/bpftool/Makefile     |  80 +++++
> > >  tools/bpf/bpftool/common.c     | 214 ++++++++++++
> > >  tools/bpf/bpftool/jit_disasm.c |  83 +++++
> > >  tools/bpf/bpftool/main.c       | 212 ++++++++++++
> > >  tools/bpf/bpftool/main.h       |  99 ++++++
> > >  tools/bpf/bpftool/map.c        | 742 +++++++++++++++++++++++++++++++++++++++++
> > >  tools/bpf/bpftool/prog.c       | 392 ++++++++++++++++++++++
> > >  8 files changed, 1837 insertions(+), 3 deletions(-)    
> > ...  
> > > +static int do_help(int argc, char **argv)
> > > +{
> > > +	fprintf(stderr,
> > > +		"Usage: %s %s show   [MAP]\n"
> > > +		"       %s %s dump    MAP\n"
> > > +		"       %s %s update  MAP  key BYTES value VALUE [UPDATE_FLAGS]\n"
> > > +		"       %s %s lookup  MAP  key BYTES\n"
> > > +		"       %s %s getnext MAP [key BYTES]\n"
> > > +		"       %s %s delete  MAP  key BYTES\n"
> > > +		"       %s %s pin     MAP  FILE\n"
> > > +		"       %s %s help\n"
> > > +		"\n"
> > > +		"       MAP := { id MAP_ID | pinned FILE }\n"
> > > +		"       " HELP_SPEC_PROGRAM "\n"
> > > +		"       VALUE := { BYTES | MAP | PROG }\n"
> > > +		"       UPDATE_FLAGS := { any | exist | noexist }\n"
> > > +		"",    
> > 
> > overall looks good to me, but still difficult to grasp how to use it.
> > Can you add README with example usage and expected output?  
> 
> I have a README on GitHub, but I was thinking about perhaps writing a
> proper man page?  Do you prefer one over the other?

I would prefer adding a README.rst file, in RST-format, as the rest of
the kernel documentation is moving in that direction[1] (your github
version is in README.md format).  A man page will always be
out-of-sync, and even out-of-sync on different distros.

 See[1]: https://www.kernel.org/doc/html/latest/

And then I would find some place in Documentation/admin-guide/ and
include the README.rst file, so it shows up at [1].

RST have an include method like:

.. include:: ../../tools/bpf/bpftool/README.rst

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
