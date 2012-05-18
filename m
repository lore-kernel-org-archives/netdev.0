From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce netdev_alloc_frag()
Date: Fri, 18 May 2012 13:31:44 -0400 (EDT)
Message-ID: <20120518.133144.1518569661201765520.davem@davemloft.net>
References: <1337353932.7029.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754441Ab2ERRbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:31:46 -0400
In-Reply-To: <1337353932.7029.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 May 2012 17:12:12 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Fix two issues introduced in commit a1c7fff7e18f5
> ( net: netdev_alloc_skb() use build_skb() )
> 
> - Must be IRQ safe (non NAPI drivers can use it)
> - Must not leak the frag if build_skb() fails to allocate sk_buff
> 
> This patch introduces netdev_alloc_frag() for drivers willing to
> use build_skb() instead of __netdev_alloc_skb() variants.
> 
> Factorize code so that :
> __dev_alloc_skb() is a wrapper around __netdev_alloc_skb(), and
> dev_alloc_skb() a wrapper around netdev_alloc_skb()
> 
> Use __GFP_COLD flag.
> 
> Almost all network drivers now benefit from skb->head_frag
> infrastructure.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
