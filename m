From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [IPSEC]: Get rid of ipv6_{auth,esp,comp}_hdr
Date: Wed, 10 Oct 2007 15:45:34 -0700 (PDT)
Message-ID: <20071010.154534.124087966.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjO-00024U-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49154
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756463AbXJJWpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:45:31 -0400
In-Reply-To: <E1IfcjO-00024U-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:14 +0800

> [IPSEC]: Get rid of ipv6_{auth,esp,comp}_hdr
> 
> This patch removes the duplicate ipv6_{auth,esp,comp}_hdr structures since
> they're identical to the IPv4 versions.  Duplicating them would only create
> problems for ourselves later when we need to add things like extended
> sequence numbers.
> 
> I've also added transport header type conversion headers for these types
> which are now used by the transforms.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
