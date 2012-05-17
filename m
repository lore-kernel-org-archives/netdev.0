From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Thu, 17 May 2012 15:53:18 -0400 (EDT)
Message-ID: <20120517.155318.1557653193070030300.davem@davemloft.net>
References: <20120517164016.GL14498@1wt.eu>
	<1337273387.3403.24.camel@edumazet-glaptop>
	<1337276056.3403.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932832Ab2EQTxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 15:53:44 -0400
In-Reply-To: <1337276056.3403.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 17 May 2012 19:34:16 +0200

> [PATCH net-next] net: netdev_alloc_skb() use build_skb()
> 
> netdev_alloc_skb() is used by networks driver in their RX path to
> allocate an skb to receive an incoming frame.
> 
> With recent skb->head_frag infrastructure, it makes sense to change
> netdev_alloc_skb() to use build_skb() and a frag allocator.
> 
> This permits a zero copy splice(socket->pipe), and better GRO or TCP
> coalescing.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, we can sort out any fallout very easily before 3.5 is released.

Awesome work Eric.
