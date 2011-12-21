From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_sfq: rehash queues in perturb timer
Date: Wed, 21 Dec 2011 15:45:02 -0500 (EST)
Message-ID: <20111221.154502.1340769458825651650.davem@davemloft.net>
References: <1324474211.2728.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab1LUUpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 15:45:05 -0500
In-Reply-To: <1324474211.2728.56.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2011 14:30:11 +0100

> A known Out Of Order (OOO) problem hurts SFQ when timer changes
> perturbation value, since all new packets delivered to SFQ enqueue might
> end on different slots than previous in-flight packets.
> 
> With round robin delivery, we can thus deliver packets in a different
> order.
> 
> Since SFQ is limited to small amount of in-flight packets, we can rehash
> packets so that this OOO problem is fixed.
> 
> This rehashing is performed only if internal flow classifier is in use.
> 
> We now store in skb->cb[] the "struct flow_keys" so that we dont call
> skb_flow_dissect() again while rehashing.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
