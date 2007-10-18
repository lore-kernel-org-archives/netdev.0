From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/11] [IPSEC]: Fix length check in xfrm_parse_spi
Date: Wed, 17 Oct 2007 21:30:42 -0700 (PDT)
Message-ID: <20071017.213042.26536123.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yP-0006HD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60296
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751899AbXJREan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:30:43 -0400
In-Reply-To: <E1Ii9yP-0006HD-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:13 +0800

> [IPSEC]: Fix length check in xfrm_parse_spi
> 
> Currently xfrm_parse_spi requires there to be 16 bytes for AH and ESP.
> In contrived cases there may not actually be 16 bytes there since the
> respective header sizes are less than that (8 and 12 currently).
> 
> This patch changes the test to use the actual header length instead of 16.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
