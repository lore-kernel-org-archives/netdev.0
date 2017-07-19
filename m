From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master 0/3] BPF updates
Date: Tue, 18 Jul 2017 17:23:03 -0700
Message-ID: <20170718172303.2020f39c@xeon-e3>
References: <cover.1500301061.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33779 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751560AbdGSAXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 20:23:05 -0400
Received: by mail-pf0-f179.google.com with SMTP id s70so9717950pfs.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 17:23:05 -0700 (PDT)
In-Reply-To: <cover.1500301061.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Jul 2017 17:18:49 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Couple of misc updates related to BPF. First removes a BPF sample
> that is long legacy (pre BPF fs times), then we add support for the
> loader to be able to take care of map in map, and last but not least
> we dump id and whether prog was jited in tc filter show for cls/act
> BPF programs.
> 
> The set is intended for -master branch _after_ the -net-next branch
> got merged into -master branch.
> 
> Thanks!
> 
> Daniel Borkmann (3):
>   bpf: remove obsolete samples
>   bpf: support loading map in map from obj
>   bpf: dump id/jited info for cls/act programs
> 
>  examples/bpf/bpf_agent.c      | 258 ----------------------
>  examples/bpf/bpf_map_in_map.c |  56 +++++
>  examples/bpf/bpf_prog.c       | 501 ------------------------------------------
>  examples/bpf/bpf_shared.h     |  22 --
>  examples/bpf/bpf_sys.h        |  23 --
>  include/bpf_elf.h             |   2 +
>  include/bpf_util.h            |   2 +
>  lib/bpf.c                     | 205 ++++++++++++++++-
>  tc/f_bpf.c                    |   3 +
>  tc/m_bpf.c                    |   3 +
>  10 files changed, 261 insertions(+), 814 deletions(-)
>  delete mode 100644 examples/bpf/bpf_agent.c
>  create mode 100644 examples/bpf/bpf_map_in_map.c
>  delete mode 100644 examples/bpf/bpf_prog.c
>  delete mode 100644 examples/bpf/bpf_shared.h
>  delete mode 100644 examples/bpf/bpf_sys.h
> 

Applied.
