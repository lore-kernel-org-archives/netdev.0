From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/24] [IPSEC]: Move flow construction into
 xfrm_dst_lookup
Date: Tue, 13 Nov 2007 21:37:39 -0800 (PST)
Message-ID: <20071113.213739.260545863.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZy-0001HD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37458
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757286AbXKNFhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:37:40 -0500
In-Reply-To: <E1IplZy-0001HD-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:26 +0800

> [IPSEC]: Move flow construction into xfrm_dst_lookup
> 
> This patch moves the flow construction from the callers of xfrm_dst_lookup
> into that function.  It also changes xfrm_dst_lookup so that it takes an
> xfrm state as its argument instead of explicit addresses.
> 
> This removes any address-specific logic from the callers of xfrm_dst_lookup
> which is needed to correctly support inter-family transforms.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
