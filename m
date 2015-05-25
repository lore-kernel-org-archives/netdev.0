From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test_bpf: add more eBPF jump torture cases
Date: Mon, 25 May 2015 00:15:36 -0400 (EDT)
Message-ID: <20150525.001536.383553511855379504.davem@davemloft.net>
References: <b23d3a10edbe46ac70bcc57a05ece597e1b6c09c.1432335952.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852AbbEYEPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 00:15:38 -0400
In-Reply-To: <b23d3a10edbe46ac70bcc57a05ece597e1b6c09c.1432335952.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 23 May 2015 01:10:07 +0200

> Add two more eBPF test cases for JITs, i.e. the second one revealed a
> bug in the x86_64 JIT compiler, where only an int3 filled image from
> the allocator was emitted and later wrongly set by the compiler as the
> bpf_func program code since optimization pass boundary was surpassed
> w/o actually emitting opcodes.
> 
> Interpreter:
> 
>   [   45.782892] test_bpf: #242 BPF_MAXINSNS: Very long jump backwards jited:0 11 PASS
>   [   45.783062] test_bpf: #243 BPF_MAXINSNS: Edge hopping nuthouse jited:0 14705 PASS
> 
> After x86_64 JIT (fixed):
> 
>   [   80.495638] test_bpf: #242 BPF_MAXINSNS: Very long jump backwards jited:1 6 PASS
>   [   80.495957] test_bpf: #243 BPF_MAXINSNS: Edge hopping nuthouse jited:1 17157 PASS
> 
> Reference: http://thread.gmane.org/gmane.linux.network/364729
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thank you.
