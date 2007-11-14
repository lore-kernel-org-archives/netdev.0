From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/24] [IPSEC]: Only set neighbour on top xfrm dst
Date: Tue, 13 Nov 2007 21:35:12 -0800 (PST)
Message-ID: <20071113.213512.01611951.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZu-0001Gd-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37445
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbXKNFfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:35:13 -0500
In-Reply-To: <E1IplZu-0001Gd-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:22 +0800

> [IPSEC]: Only set neighbour on top xfrm dst
> 
> The neighbour field is only used by dst_confirm which only ever happens on
> the top-most xfrm dst.  So it's a waste to duplicate for every other xfrm
> dst.  This patch moves its setting out of the loop so that only the top one
> gets set.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
