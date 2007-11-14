From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/24] [IPV6]: Move nfheader_len into rt6_info
Date: Tue, 13 Nov 2007 21:33:43 -0800 (PST)
Message-ID: <20071113.213343.253972347.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZr-0001GC-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37435
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbXKNFdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:33:44 -0500
In-Reply-To: <E1IplZr-0001GC-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:19 +0800

> [IPV6]: Move nfheader_len into rt6_info
> 
> The dst member nfheader_len is only used by IPv6.  It's also currently
> creating a rather ugly alignment hole in struct dst.  Therefore this patch
> moves it from there into struct rt6_info.
> 
> It also reorders the fields in rt6_info to minimize holes.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
