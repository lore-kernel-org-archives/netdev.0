From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 2/2] tools: bpf: add bpftool
Date: Wed, 27 Sep 2017 00:02:08 +0100
Message-ID: <20170927000208.4396dfb7@cakuba>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
        <20170926153522.31500-3-jakub.kicinski@netronome.com>
        <20170926222405.nq23enzudbjklczb@ast-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:44183 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964903AbdIZXCZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 19:02:25 -0400
Received: by mail-wr0-f175.google.com with SMTP id v109so14396487wrc.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 16:02:25 -0700 (PDT)
In-Reply-To: <20170926222405.nq23enzudbjklczb@ast-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 15:24:06 -0700, Alexei Starovoitov wrote:
> On Tue, Sep 26, 2017 at 08:35:22AM -0700, Jakub Kicinski wrote:
> > Add a simple tool for querying and updating BPF objects on the system.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > Reviewed-by: Simon Horman <simon.horman@netronome.com>
> > ---
> >  tools/bpf/Makefile             |  18 +-
> >  tools/bpf/bpftool/Makefile     |  80 +++++
> >  tools/bpf/bpftool/common.c     | 214 ++++++++++++
> >  tools/bpf/bpftool/jit_disasm.c |  83 +++++
> >  tools/bpf/bpftool/main.c       | 212 ++++++++++++
> >  tools/bpf/bpftool/main.h       |  99 ++++++
> >  tools/bpf/bpftool/map.c        | 742 +++++++++++++++++++++++++++++++++++++++++
> >  tools/bpf/bpftool/prog.c       | 392 ++++++++++++++++++++++
> >  8 files changed, 1837 insertions(+), 3 deletions(-)  
> ...
> > +static int do_help(int argc, char **argv)
> > +{
> > +	fprintf(stderr,
> > +		"Usage: %s %s show   [MAP]\n"
> > +		"       %s %s dump    MAP\n"
> > +		"       %s %s update  MAP  key BYTES value VALUE [UPDATE_FLAGS]\n"
> > +		"       %s %s lookup  MAP  key BYTES\n"
> > +		"       %s %s getnext MAP [key BYTES]\n"
> > +		"       %s %s delete  MAP  key BYTES\n"
> > +		"       %s %s pin     MAP  FILE\n"
> > +		"       %s %s help\n"
> > +		"\n"
> > +		"       MAP := { id MAP_ID | pinned FILE }\n"
> > +		"       " HELP_SPEC_PROGRAM "\n"
> > +		"       VALUE := { BYTES | MAP | PROG }\n"
> > +		"       UPDATE_FLAGS := { any | exist | noexist }\n"
> > +		"",  
> 
> overall looks good to me, but still difficult to grasp how to use it.
> Can you add README with example usage and expected output?

I have a README on GitHub, but I was thinking about perhaps writing a
proper man page?  Do you prefer one over the other?

> Acked-by: Alexei Starovoitov <ast@kernel.org>

Thanks!

> You also realize that you're signing up maintaining this tool, right? ;)

Yes :)
