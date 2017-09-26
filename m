From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] tools: bpf: add bpftool
Date: Tue, 26 Sep 2017 15:24:06 -0700
Message-ID: <20170926222405.nq23enzudbjklczb@ast-mbp>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
 <20170926153522.31500-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, davem@davemloft.net,
        hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37457 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031284AbdIZWYK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 18:24:10 -0400
Received: by mail-pg0-f67.google.com with SMTP id v5so7503088pgn.4
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 15:24:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170926153522.31500-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 08:35:22AM -0700, Jakub Kicinski wrote:
> Add a simple tool for querying and updating BPF objects on the system.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---
>  tools/bpf/Makefile             |  18 +-
>  tools/bpf/bpftool/Makefile     |  80 +++++
>  tools/bpf/bpftool/common.c     | 214 ++++++++++++
>  tools/bpf/bpftool/jit_disasm.c |  83 +++++
>  tools/bpf/bpftool/main.c       | 212 ++++++++++++
>  tools/bpf/bpftool/main.h       |  99 ++++++
>  tools/bpf/bpftool/map.c        | 742 +++++++++++++++++++++++++++++++++++++++++
>  tools/bpf/bpftool/prog.c       | 392 ++++++++++++++++++++++
>  8 files changed, 1837 insertions(+), 3 deletions(-)
...
> +static int do_help(int argc, char **argv)
> +{
> +	fprintf(stderr,
> +		"Usage: %s %s show   [MAP]\n"
> +		"       %s %s dump    MAP\n"
> +		"       %s %s update  MAP  key BYTES value VALUE [UPDATE_FLAGS]\n"
> +		"       %s %s lookup  MAP  key BYTES\n"
> +		"       %s %s getnext MAP [key BYTES]\n"
> +		"       %s %s delete  MAP  key BYTES\n"
> +		"       %s %s pin     MAP  FILE\n"
> +		"       %s %s help\n"
> +		"\n"
> +		"       MAP := { id MAP_ID | pinned FILE }\n"
> +		"       " HELP_SPEC_PROGRAM "\n"
> +		"       VALUE := { BYTES | MAP | PROG }\n"
> +		"       UPDATE_FLAGS := { any | exist | noexist }\n"
> +		"",

overall looks good to me, but still difficult to grasp how to use it.
Can you add README with example usage and expected output?

Acked-by: Alexei Starovoitov <ast@kernel.org>

You also realize that you're signing up maintaining this tool, right? ;)
