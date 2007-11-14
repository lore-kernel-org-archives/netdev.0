From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/24] [IPSEC]: Store xfrm states in security path
 directly
Date: Tue, 13 Nov 2007 21:45:07 -0800 (PST)
Message-ID: <20071113.214507.68418182.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplaB-0001In-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39579
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750893AbXKNFpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:45:13 -0500
In-Reply-To: <E1IplaB-0001In-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:39 +0800

> [IPSEC]: Store xfrm states in security path directly
> 
> As it is xfrm_input first collects a list of xfrm states on the stack
> before storing them in the packet's security path just before it returns.
> For async crypto, this construction presents an obstacle since we may
> need to leave the loop after each transform.
> 
> In fact, it's much easier to just skip the stack completely and always
> store to the security path.  This is proven by the fact that this patch
> actually shrinks the code.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
