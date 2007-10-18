From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/11] [IPSEC]: Get nexthdr from caller in xfrm6_rcv_spi
Date: Wed, 17 Oct 2007 21:29:32 -0700 (PDT)
Message-ID: <20071017.212932.27779199.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yM-0006Gx-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60286
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751682AbXJRE3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:29:33 -0400
In-Reply-To: <E1Ii9yM-0006Gx-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:10 +0800

> [IPSEC]: Get nexthdr from caller in xfrm6_rcv_spi
> 
> Currently xfrm6_rcv_spi gets the nexthdr value itself from the packet.
> This means that we need to fix up the value in case we have a 4-on-6
> tunnel.  Moving this logic into the caller simplifies things and allows
> us to merge the code with IPv4.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
