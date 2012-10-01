From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: dont orphan skbs in mlx4_en_xmit()
Date: Mon, 01 Oct 2012 17:03:05 -0400 (EDT)
Message-ID: <20121001.170305.1749278118378383172.davem@davemloft.net>
References: <953B660C027164448AE903364AC447D28721B46E@MTLDAG01.mtl.com>
	<1348056777.26523.750.camel@edumazet-glaptop>
	<1348854806.5093.2686.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp@mellanox.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab2JAVDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:03:11 -0400
In-Reply-To: <1348854806.5093.2686.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Sep 2012 19:53:26 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> After commit e22979d96a55d (mlx4_en: Moving to Interrupts for TX
> completions) we no longer need to orphan skbs in mlx4_en_xmit()
> since skb wont stay a long time in TX ring before their release.
> 
> Orphaning skbs in ndo_start_xmit() should be avoided as much as
> possible, since it breaks TCP Small Queue or other flow control
> mechanisms (per socket limits)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
