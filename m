From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/11] [IPSEC]: Use the top IPv4 route's peer instead of
 the bottom
Date: Wed, 17 Oct 2007 21:34:55 -0700 (PDT)
Message-ID: <20071017.213455.13773024.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yT-0006Hj-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56796
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752254AbXJREe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:34:56 -0400
In-Reply-To: <E1Ii9yT-0006Hj-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:17 +0800

> [IPSEC]: Use the top IPv4 route's peer instead of the bottom
> 
> For IPv4 we were using the bottom route's peer instead of the top one.
> This is wrong because the peer is only used by TCP to keep track of
> information about the TCP destination address which certainly does not
> live in the bottom route.
> 
> This patch fixes that which allows us to get rid of the family check
> since the bottom route could be IPv6 while the top one must always
> be IPv4.
> 
> I've also changed the other fields which are IPv4-specific to get the
> info from the top route instead of potentially bogus data from the
> bottom route.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
