From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] tunnels: missing rcu_assign_pointer()
Date: Thu, 09 Sep 2010 15:02:51 -0700 (PDT)
Message-ID: <20100909.150251.48516443.davem@davemloft.net>
References: <1284046423.2589.188.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455Ab0IIWCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 18:02:33 -0400
In-Reply-To: <1284046423.2589.188.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Sep 2010 17:33:43 +0200

> xfrm4_tunnel_register() & xfrm6_tunnel_register() should
> use rcu_assign_pointer() to make sure previous writes
> (to handler->next) are committed to memory before chain
> insertion.
> 
> deregister functions dont need a particular barrier.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
