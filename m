From: David Miller <davem@davemloft.net>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 15:55:20 -0500 (EST)
Message-ID: <20111221.155520.1406613141134089105.davem@davemloft.net>
References: <4EF1EC28.90008@monstr.eu>
	<1324483144.2301.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1324487504.2301.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: monstr@monstr.eu, john.williams@petalogix.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55328 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1LUUzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:55:24 -0500
In-Reply-To: <1324487504.2301.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 18:11:44 +0100

> [PATCH net-next] net: relax rcvbuf limits
> 
> skb->truesize might be big even for a small packet.
> 
> Its even bigger after commit 87fb4b7b533 (net: more accurate skb
> truesize) and big MTU.
> 
> We should allow queueing at least one packet per receiver, even with a
> low RCVBUF setting.
> 
> Reported-by: Michal Simek <monstr@monstr.eu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next, although I was tempted to put it into net.

We may end up backporting this into -stable at some point, we'll
see.
