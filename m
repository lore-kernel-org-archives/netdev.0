From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ip_gre: CONFIG_IPV6_MODULE support
Date: Wed, 29 Sep 2010 16:57:58 +0900
Message-ID: <20100929075758.GA5188@gondor.apana.org.au>
References: <20100928.214132.226782961.davem@davemloft.net> <20100928.223850.104051485.davem@davemloft.net> <1285742848.22570.53.camel@edumazet-laptop> <20100929.002544.183044247.davem@davemloft.net> <1285746352.2615.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47479 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab0I2H6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 03:58:03 -0400
Content-Disposition: inline
In-Reply-To: <1285746352.2615.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 29, 2010 at 09:45:52AM +0200, Eric Dumazet wrote:
.
> > > install ipv6 /bin/true
> > > 
> > > or
> > > 
> > > options ipv6 disable=1
> > 
> > If you set the disable option, it should do the right thing.  Since
> > the ipv6 symbols will be available, yet the ipv6 stack won't by
> > default bring up ipv6 addresses onto interfaces etc.
> 
> I must miss something obvious.
> 
> David, with your patch, I cant :
> 
> install ipv6 /bin/true
> modprobe ip_gre

Does it work if you use

	options ipv6 disable=1

If so then that's what should be used in this case.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
