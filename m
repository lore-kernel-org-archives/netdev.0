From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/24] [IPV4]: Add ip_local_out
Date: Tue, 13 Nov 2007 21:42:18 -0800 (PST)
Message-ID: <20071113.214218.92332799.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla5-0001I8-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752282AbXKNFmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:42:19 -0500
In-Reply-To: <E1Ipla5-0001I8-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:33 +0800

> [IPV4]: Add ip_local_out
> 
> Most callers of the LOCAL_OUT chain will set the IP packet length
> and header checksum before doing so.  They also share the same output
> function dst_output.
> 
> This patch creates a new function called ip_local_out which does all
> of that and converts the appropriate users over to it.
> 
> Apart from removing duplicate code, it will also help in merging the
> IPsec output path once the same thing is done for IPv6.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
