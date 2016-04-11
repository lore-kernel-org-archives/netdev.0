From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master 0/3] Minor tc/bpf updates
Date: Mon, 11 Apr 2016 14:55:26 -0700
Message-ID: <20160411145526.1c12f6fe@xeon-e3>
References: <cover.1460153854.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35435 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbcDKVzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 17:55:17 -0400
Received: by mail-pf0-f171.google.com with SMTP id n1so131809974pfn.2
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 14:55:16 -0700 (PDT)
In-Reply-To: <cover.1460153854.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  9 Apr 2016 00:32:02 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Some minor updates to improve error reporting, add signatures
> and recently introduced map flags attribute. Set is against
> master branch.
> 
> Thanks!
> 
> Daniel Borkmann (3):
>   tc, bpf: add new csum and tunnel signatures
>   tc, bpf: further improve error reporting
>   tc, bpf: add support for map pre/allocation
> 
>  examples/bpf/bpf_cyclic.c   |  9 ++++-
>  examples/bpf/bpf_graft.c    |  8 +++-
>  examples/bpf/bpf_prog.c     |  2 +
>  examples/bpf/bpf_shared.c   |  8 +++-
>  examples/bpf/bpf_tailcall.c | 29 ++++++++++++--
>  include/bpf_api.h           | 52 ++++--------------------
>  include/bpf_elf.h           |  1 +
>  tc/tc_bpf.c                 | 98 +++++++++++++++++++++++++++++++++++----------
>  tc/tc_bpf.h                 |  4 ++
>  9 files changed, 138 insertions(+), 73 deletions(-)
> 

Applied thanks
