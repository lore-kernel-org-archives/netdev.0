From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH net-next v2 0/3] tools: add bpftool
Date: Tue, 3 Oct 2017 17:19:42 -0300
Message-ID: <20171003201942.GH25388@kernel.org>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37414 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750812AbdJCUTr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 16:19:47 -0400
Content-Disposition: inline
In-Reply-To: <20171002231130.12406-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Oct 02, 2017 at 04:11:27PM -0700, Jakub Kicinski escreveu:
> Hi!
> 
> This set adds bpftool to the tools/ directory.  The first 
> patch renames tools/net to tools/bpf, the second one adds 
> the new code, while the third adds simple documentation.
> 
> v2:
>  - report names, map ids, load time, uid;
>  - add docs/man pages;
>  - general cleanups & fixes.
> 
> Thanks to David Beckett for help with docs and testing.

Why not call it just 'bpf'?

- Arnaldo
 
> Jakub Kicinski (3):
>   tools: rename tools/net directory to tools/bpf
>   tools: bpf: add bpftool
>   tools: bpftool: add documentation
> 
>  MAINTAINERS                                      |   3 +-
>  tools/Makefile                                   |  14 +-
>  tools/{net => bpf}/Makefile                      |  18 +-
>  tools/{net => bpf}/bpf_asm.c                     |   0
>  tools/{net => bpf}/bpf_dbg.c                     |   0
>  tools/{net => bpf}/bpf_exp.l                     |   0
>  tools/{net => bpf}/bpf_exp.y                     |   0
>  tools/{net => bpf}/bpf_jit_disasm.c              |   0
>  tools/bpf/bpftool/Documentation/Makefile         |  34 ++
>  tools/bpf/bpftool/Documentation/bpftool-map.txt  | 110 ++++
>  tools/bpf/bpftool/Documentation/bpftool-prog.txt |  81 +++
>  tools/bpf/bpftool/Documentation/bpftool.txt      |  34 ++
>  tools/bpf/bpftool/Makefile                       |  86 +++
>  tools/bpf/bpftool/common.c                       | 215 +++++++
>  tools/bpf/bpftool/jit_disasm.c                   |  87 +++
>  tools/bpf/bpftool/main.c                         | 212 +++++++
>  tools/bpf/bpftool/main.h                         |  99 +++
>  tools/bpf/bpftool/map.c                          | 744 +++++++++++++++++++++++
>  tools/bpf/bpftool/prog.c                         | 427 +++++++++++++
>  19 files changed, 2152 insertions(+), 12 deletions(-)
>  rename tools/{net => bpf}/Makefile (74%)
>  rename tools/{net => bpf}/bpf_asm.c (100%)
>  rename tools/{net => bpf}/bpf_dbg.c (100%)
>  rename tools/{net => bpf}/bpf_exp.l (100%)
>  rename tools/{net => bpf}/bpf_exp.y (100%)
>  rename tools/{net => bpf}/bpf_jit_disasm.c (100%)
>  create mode 100644 tools/bpf/bpftool/Documentation/Makefile
>  create mode 100644 tools/bpf/bpftool/Documentation/bpftool-map.txt
>  create mode 100644 tools/bpf/bpftool/Documentation/bpftool-prog.txt
>  create mode 100644 tools/bpf/bpftool/Documentation/bpftool.txt
>  create mode 100644 tools/bpf/bpftool/Makefile
>  create mode 100644 tools/bpf/bpftool/common.c
>  create mode 100644 tools/bpf/bpftool/jit_disasm.c
>  create mode 100644 tools/bpf/bpftool/main.c
>  create mode 100644 tools/bpf/bpftool/main.h
>  create mode 100644 tools/bpf/bpftool/map.c
>  create mode 100644 tools/bpf/bpftool/prog.c
> 
> -- 
> 2.14.1
