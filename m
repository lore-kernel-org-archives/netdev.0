From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/7] [IPSEC] beet: Fix extension header support on
 output
Date: Wed, 10 Oct 2007 15:42:33 -0700 (PDT)
Message-ID: <20071010.154233.108812400.davem@davemloft.net>
References: <20071010143915.GA7650@gondor.apana.org.au>
	<E1IfcjL-000246-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47577
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756262AbXJJWmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:42:31 -0400
In-Reply-To: <E1IfcjL-000246-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 10 Oct 2007 22:40:11 +0800

> [IPSEC] beet: Fix extension header support on output
> 
> The beet output function completely kills any extension headers by replacing
> them with the IPv6 header.  This is because it essentially ignores the
> result of ip6_find_1stfragopt by simply acting as if there aren't any
> extension headers.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
