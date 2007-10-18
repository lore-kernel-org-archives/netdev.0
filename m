From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/11] [IPSEC]: Fix pure tunnel modes involving IPv6
Date: Wed, 17 Oct 2007 21:28:16 -0700 (PDT)
Message-ID: <20071017.212816.69410859.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yK-0006Ga-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60275
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752246AbXJRE2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:28:24 -0400
In-Reply-To: <E1Ii9yK-0006Ga-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:08 +0800

> [IPSEC]: Fix pure tunnel modes involving IPv6
> 
> I noticed that my recent patch broke 6-on-4 pure IPsec tunnels (the ones
> that are only used for incompressible IPsec packets).  Subsequent reviews
> show that I broke 6-on-6 pure tunnels more than three years ago and nobody
> ever noticed. I suppose every must be testing 6-on-6 IPComp with large
> pings which are very compressible :)
> 
> This patch fixes both cases.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
