From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] PPC: bpf_jit_comp: add SKF_AD_PKTTYPE instruction
Date: Mon, 03 Nov 2014 12:06:33 -0500 (EST)
Message-ID: <20141103.120633.183870310578884991.davem@davemloft.net>
References: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	alexei.starovoitov@gmail.com, mpe@ellerman.id.au, matt@ozlabs.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752352AbaKCRGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:06:37 -0500
In-Reply-To: <1414649535-3956-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Thu, 30 Oct 2014 09:12:15 +0300

> Add BPF extension SKF_AD_PKTTYPE to ppc JIT to load
> skb->pkt_type field.
> 
> Before:
> [   88.262622] test_bpf: #11 LD_IND_NET 86 97 99 PASS
> [   88.265740] test_bpf: #12 LD_PKTTYPE 109 107 PASS
> 
> After:
> [   80.605964] test_bpf: #11 LD_IND_NET 44 40 39 PASS
> [   80.607370] test_bpf: #12 LD_PKTTYPE 9 9 PASS
> 
> CC: Alexei Starovoitov<alexei.starovoitov@gmail.com>
> CC: Michael Ellerman<mpe@ellerman.id.au>
> Cc: Matt Evans <matt@ozlabs.org>
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> 
> v2: Added test rusults

So, can I apply this now?
