From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inetpeer: __rcu annotations
Date: Wed, 27 Oct 2010 11:22:45 -0700 (PDT)
Message-ID: <20101027.112245.232739163.davem@davemloft.net>
References: <1288086938.3169.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754798Ab0J0SWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:22:22 -0400
In-Reply-To: <1288086938.3169.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Oct 2010 11:55:38 +0200

> Adds __rcu annotations to inetpeer
> 	(struct inet_peer)->avl_left
> 	(struct inet_peer)->avl_right
> 
> This is a tedious cleanup, but removes one smp_wmb() from link_to_pool()
> since we now use more self documenting rcu_assign_pointer().
> 
> Note the use of RCU_INIT_POINTER() instead of rcu_assign_pointer() in
> all cases we dont need a memory barrier.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
