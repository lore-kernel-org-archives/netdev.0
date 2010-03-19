From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: Potential null skb->dev dereference
Date: Thu, 18 Mar 2010 21:16:57 -0700 (PDT)
Message-ID: <20100318.211657.35047904.davem@davemloft.net>
References: <1268954378.2894.201.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750836Ab0CSEQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 00:16:34 -0400
In-Reply-To: <1268954378.2894.201.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 00:19:38 +0100

> When doing "ifenslave -d bond0 eth0", there is chance to get NULL
> dereference in netif_receive_skb(), because dev->master suddenly becomes
> NULL after we tested it.
> 
> We should use ACCESS_ONCE() to avoid this (or rcu_dereference())
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
