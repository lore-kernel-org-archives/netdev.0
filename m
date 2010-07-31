From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] bridge leaks 3 references on lo per up&down
Date: Fri, 30 Jul 2010 23:37:17 -0700 (PDT)
Message-ID: <20100730.233717.260088691.davem@davemloft.net>
References: <20100728095825.GC13413@jupiter.n2.diac24.net>
	<20100728120336.GD13413@jupiter.n2.diac24.net>
	<20100729111231.GA30021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: equinox@diac24.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46747
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754361Ab0GaGhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jul 2010 02:37:00 -0400
In-Reply-To: <20100729111231.GA30021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Jul 2010 19:12:31 +0800

> bridge: Fix skb leak when multicast parsing fails on TX
> 
> On the bridge TX path we're leaking an skb when br_multicast_rcv
> returns an error.
> 
> Reported-by: David Lamparter <equinox@diac24.net>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6, thanks!
