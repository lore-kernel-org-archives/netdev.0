From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 14/24] [INET]: Give outer DSCP directly to ip*_copy_dscp
Date: Tue, 13 Nov 2007 21:40:24 -0800 (PST)
Message-ID: <20071113.214024.59414658.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla2-0001Hj-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757676AbXKNFkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:40:25 -0500
In-Reply-To: <E1Ipla2-0001Hj-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:30 +0800

> [INET]: Give outer DSCP directly to ip*_copy_dscp
> 
> This patch changes the prototype of ipv4_copy_dscp and ipv6_copy_dscp so
> that they directly take the outer DSCP rather than the outer IP header.
> This will help us to unify the code for inter-family tunnels.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
