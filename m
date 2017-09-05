From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master 0/2] Two minor BPF updates
Date: Tue, 5 Sep 2017 09:27:11 -0700
Message-ID: <20170905092711.48f7a582@xeon-e3>
References: <cover.1504570627.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36619 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751896AbdIEQ1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:27:18 -0400
Received: by mail-pf0-f178.google.com with SMTP id e199so8594217pfh.3
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 09:27:18 -0700 (PDT)
In-Reply-To: <cover.1504570627.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Sep 2017 02:24:30 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Two minor updates including a small cleanup for dumping
> the trace pipe and one for consolidating prog dumps for
> tc and xdp to use bpf_prog_info_by_fd() when possible.
> 
> Thanks!
> 
> Daniel Borkmann (2):
>   bpf: minor cleanups for bpf_trace_pipe
>   bpf: consolidate dumps to use bpf_dump_prog_info
> 
>  include/bpf_util.h |  2 +-
>  ip/ipaddress.c     |  6 ++++--
>  ip/iplink_xdp.c    | 19 +++++++++++++++----
>  ip/xdp.h           |  2 +-
>  lib/bpf.c          | 31 ++++++++++++++++++-------------
>  tc/f_bpf.c         |  8 ++++----
>  tc/m_bpf.c         |  8 ++++----
>  7 files changed, 47 insertions(+), 29 deletions(-)
> 

Applied, thanks Daniel
