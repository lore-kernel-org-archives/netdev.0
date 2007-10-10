From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [IPSEC] esp: Remove NAT-T checksum invalidation
 for BEET
Date: Wed, 10 Oct 2007 15:42:01 -0700 (PDT)
Message-ID: <20071010.154201.82695513.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjK-00023y-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756212AbXJJWl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:41:59 -0400
In-Reply-To: <E1IfcjK-00023y-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:10 +0800

> [IPSEC] esp: Remove NAT-T checksum invalidation for BEET
> 
> I pointed this out back when this patch was first proposed but it looks like
> it got lost along the way.
> 
> The checksum only needs to be ignored for NAT-T in transport mode where
> we lose the original inner addresses due to NAT.  With BEET the inner
> addresses will be intact so the checksum remains valid.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
