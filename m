From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Make icmp route lookup code a bit clearer.
Date: Tue, 01 Mar 2011 15:50:15 -0800 (PST)
Message-ID: <20110301.155015.258117084.davem@davemloft.net>
References: <20110301.154816.212683830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40487
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755950Ab1CAXti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 18:49:38 -0500
In-Reply-To: <20110301.154816.212683830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 01 Mar 2011 15:48:16 -0800 (PST)

> 
> The route lookup code in icmp_send() is slightly tricky as a result of
> having to handle all of the requirements of RFC 4301 host relookups.
> 
> Pull the route resolution into a seperate function, so that the error
> handling and route reference counting is hopefully easier to see and
> contained wholly within this new routine.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
...
> +struct rtable *icmp_route_lookup(struct net *net, struct sk_buff *skb_in,

Of course this should be static :-)
