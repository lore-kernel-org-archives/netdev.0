From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master resend 0/4] Minor BPF updates on
 frontend
Date: Sun, 7 Feb 2016 11:31:26 -0800
Message-ID: <20160207113126.775ab8dd@xeon-e3>
References: <cover.1454806938.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34647 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbcBGTbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:31:14 -0500
Received: by mail-pf0-f178.google.com with SMTP id o185so97844970pfb.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 11:31:13 -0800 (PST)
In-Reply-To: <cover.1454806938.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  7 Feb 2016 02:11:49 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Couple of minor updates on tc frontend.
> 
> Resending with no changes and with John's Acked-by kept, orignal
> version got set to 'Changes requested' by mistake.
> 
> Thanks!
> 
> Daniel Borkmann (4):
>   tc, bpf, examples: further bpf_api improvements
>   tc, bpf: improve verifier logging
>   tc, bpf: give some more hints wrt false relos
>   tc, bpf: use bind/type macros from gelf
> 
>  examples/bpf/bpf_cyclic.c   |   4 +-
>  examples/bpf/bpf_graft.c    |  13 +---
>  examples/bpf/bpf_prog.c     |  26 +++----
>  examples/bpf/bpf_shared.c   |   3 +-
>  examples/bpf/bpf_tailcall.c |  12 +--
>  include/bpf_api.h           |  56 ++++++++++++--
>  tc/tc_bpf.c                 | 173 +++++++++++++++++++++++++++++++-------------
>  tc/tc_bpf.h                 |   1 -
>  8 files changed, 191 insertions(+), 97 deletions(-)
> 

Applied.
