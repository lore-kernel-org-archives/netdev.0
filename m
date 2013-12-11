From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] udp: ipv4: fix potential use after free in
 udp_v4_early_demux()
Date: Wed, 11 Dec 2013 16:16:49 -0500 (EST)
Message-ID: <20131211.161649.858953352616918428.davem@davemloft.net>
References: <1386723287.30495.352.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386727643.30495.363.camel@edumazet-glaptop2.roam.corp.google.com>
	<1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sbohrer@rgmadvisors.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab3LKVQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 16:16:52 -0500
In-Reply-To: <1386778205.30495.374.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 11 Dec 2013 08:10:05 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> pskb_may_pull() can reallocate skb->head, we need to move the
> initialization of iph and uh pointers after its call.
> 
> Fixes: 421b3885bf6d ("udp: ipv4: Add udp early demux")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>

Applied, thanks Eric.
