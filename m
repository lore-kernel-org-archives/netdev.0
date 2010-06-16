From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: restore small inet_peer
 structures
Date: Wed, 16 Jun 2010 11:56:18 -0700 (PDT)
Message-ID: <20100616.115618.71114885.davem@davemloft.net>
References: <1276699933.2632.102.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56945
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759408Ab0FPS4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 14:56:07 -0400
In-Reply-To: <1276699933.2632.102.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Jun 2010 16:52:13 +0200

> Addition of rcu_head to struct inet_peer added 16bytes on 64bit arches.
> 
> Thats a bit unfortunate, since old size was exactly 64 bytes.
> 
> This can be solved, using an union between this rcu_head an four fields,
> that are normally used only when a refcount is taken on inet_peer.
> rcu_head is used only when refcnt=-1, right before structure freeing.
> 
> Add a inet_peer_refcheck() function to check this assertion for a while.
> 
> We can bring back SLAB_HWCACHE_ALIGN qualifier in kmem cache creation.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
