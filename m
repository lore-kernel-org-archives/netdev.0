From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/24] [IPSEC]: Set dst->input to dst_discard
Date: Tue, 13 Nov 2007 21:35:43 -0800 (PST)
Message-ID: <20071113.213543.48915899.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZv-0001Go-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37449
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754944AbXKNFfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:35:44 -0500
In-Reply-To: <E1IplZv-0001Go-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:23 +0800

> [IPSEC]: Set dst->input to dst_discard
> 
> The input function should never be invoked on IPsec dst objects.  This is
> because we don't apply IPsec on input until after we've made the routing
> decision.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
