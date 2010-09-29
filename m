From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 17:03:03 +0900
Message-ID: <20100929080303.GA5318@gondor.apana.org.au>
References: <20100929.002544.183044247.davem@davemloft.net> <1285746352.2615.11.camel@edumazet-laptop> <20100929075758.GA5188@gondor.apana.org.au> <20100929.010056.115931816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52707 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab0I2IDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:03:08 -0400
Content-Disposition: inline
In-Reply-To: <20100929.010056.115931816.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 01:00:56AM -0700, David Miller wrote:
.
> > 	options ipv6 disable=1
> > 
> > If so then that's what should be used in this case.
> 
> That's what one should use "always" :-)
> 
> Bonding has the same issue, and it's why we added the
> disable module option, so that the /bin/true stupidity
> could stop.

Right, that settles it :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
