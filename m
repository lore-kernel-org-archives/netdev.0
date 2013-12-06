From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce dev_consume_skb_any()
Date: Fri, 06 Dec 2013 15:24:36 -0500 (EST)
Message-ID: <20131206.152436.287525112174057174.davem@davemloft.net>
References: <CAJZOPZ+bkvg4G6qzY6YmMui9-KmGmpHyFCJUD2xsFLOXm12rgA@mail.gmail.com>
	<1386115199.30495.44.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LFUYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 15:24:37 -0500
In-Reply-To: <1386247508.30495.180.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Dec 2013 04:45:08 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Some network drivers use dev_kfree_skb_any() and dev_kfree_skb_irq()
> helpers to free skbs, both for dropped packets and TX completed ones.
> 
> We need to separate the two causes to get better diagnostics
> given by dropwatch or "perf record -e skb:kfree_skb"
> 
> This patch provides two new helpers, dev_consume_skb_any() and
> dev_consume_skb_irq() to be used for consumed skbs.
> 
> __dev_kfree_skb_irq() is slightly optimized to remove one
> atomic_dec_and_test() in fast path, and use this_cpu_{r|w} accessors.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
