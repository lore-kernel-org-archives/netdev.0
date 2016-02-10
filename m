From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: fix branch offset adjustment on backjumps
 after patching ctx expansion
Date: Wed, 10 Feb 2016 17:02:12 -0500 (EST)
Message-ID: <20160210.170212.1863380328830638787.davem@davemloft.net>
References: <f0e3ee64ddd8d92894d87b10f2f6e83f9a6cd33e.1454792171.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbcBJWO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 17:14:29 -0500
In-Reply-To: <f0e3ee64ddd8d92894d87b10f2f6e83f9a6cd33e.1454792171.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 10 Feb 2016 16:47:11 +0100

> When ctx access is used, the kernel often needs to expand/rewrite
> instructions, so after that patching, branch offsets have to be
> adjusted for both forward and backward jumps in the new eBPF program,
> but for backward jumps it fails to account the delta. Meaning, for
> example, if the expansion happens exactly on the insn that sits at
> the jump target, it doesn't fix up the back jump offset.
 ...
> Fixes: 9bac3d6d548e ("bpf: allow extended BPF programs access skb fields")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied and queued up for -stable, thanks Daniel.
