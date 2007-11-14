From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/24] [IPV6]: Add ip6_local_out
Date: Tue, 13 Nov 2007 21:42:48 -0800 (PST)
Message-ID: <20071113.214248.223135767.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla6-0001IG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45850
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750798AbXKNFmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:42:49 -0500
In-Reply-To: <E1Ipla6-0001IG-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:34 +0800

> [IPV6]: Add ip6_local_out
> 
> Most callers of the LOCAL_OUT chain will set the IP packet length
> before doing so.  They also share the same output function dst_output.
> 
> This patch creates a new function called ip6_local_out which does all
> of that and converts the appropriate users over to it.
> 
> Apart from removing duplicate code, it will also help in merging the
> IPsec output path.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
