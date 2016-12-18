From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] Couple of BPF fixes
Date: Sat, 17 Dec 2016 21:28:03 -0500 (EST)
Message-ID: <20161217.212803.1644338348453397032.davem@davemloft.net>
References: <cover.1482019225.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, kafai@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752059AbcLRC2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 21:28:11 -0500
In-Reply-To: <cover.1482019225.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 18 Dec 2016 01:52:56 +0100

> This set contains three BPF fixes for net, one that addresses the
> complaint from Geert wrt static allocations, and the other is a fix
> wrt mem accounting that I found recently during testing and there's
> still one more fix on the map value marking.
> 
> Thanks!
> 
> v1 -> v2:
>   - Patch 1 as is.
>   - Fixed kbuild bot issue by letting charging helpers stay in the
>     syscall.c, since there locked_vm is valid and only export the
>     ones needed by bpf_prog_realloc(). Add empty stubs in case the
>     bpf syscall is not enabled.
>   - Added patch 3 that addresses one more issue in map val marking.

Series applied, thanks Daniel.
