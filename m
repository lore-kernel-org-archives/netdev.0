From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/11] [IPSEC]: Move ip_summed zapping out of
 xfrm6_rcv_spi
Date: Wed, 17 Oct 2007 21:30:15 -0700 (PDT)
Message-ID: <20071017.213015.77061253.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yN-0006H5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60290
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751356AbXJREaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:30:16 -0400
In-Reply-To: <E1Ii9yN-0006H5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:11 +0800

> [IPSEC]: Move ip_summed zapping out of xfrm6_rcv_spi
> 
> Not every transform needs to zap ip_summed.  For example, a pure tunnel
> mode encapsulation does not affect the hardware checksum at all.  In fact,
> every algorithm (that needs this) other than AH6 already does its own
> ip_summed zapping.
> 
> This patch moves the zapping into AH6 which is in line with what IPv4 does.
> 
> Possible future optimisation: Checksum the data as we copy them in IPComp.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
