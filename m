From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next 0/3] ARM BPF JIT features
Date: Fri, 24 Jul 2015 22:31:55 -0700 (PDT)
Message-ID: <20150724.223155.121697079062172205.davem@davemloft.net>
References: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, mgherzan@gmail.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux@arm.linux.org.uk, ast@plumgrid.com
To: nschichan@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbbGYFSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 01:18:55 -0400
In-Reply-To: <1437481000-22835-1-git-send-email-nschichan@freebox.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Schichan <nschichan@freebox.fr>
Date: Tue, 21 Jul 2015 14:16:37 +0200

> This serie adds support for more instructions to the ARM BPF JIT

"series"

> namely skb netdevice type retrieval, skb payload offset retrieval, and
> skb packet type retrieval.
> 
> This allows 35 tests to use the JIT instead of 29 before.
> 
> This serie depends on the "BPF JIT fixes for ARM" serie sent earlier.

"series"

But even with that series applied these patches do not apply properly
at all.

davem@greenl8ke:~/src/GIT/net-next$ git am --signoff bundle-8569-arm-bpf-next.mbox 
Applying: ARM: net: add support for BPF_ANC | SKF_AD_PKTTYPE in ARM JIT.
error: patch failed: arch/arm/net/bpf_jit_32.c:864
error: arch/arm/net/bpf_jit_32.c: patch does not apply
Patch failed at 0001 ARM: net: add support for BPF_ANC | SKF_AD_PKTTYPE in ARM JIT.
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

Please respin against net-next, thanks.
