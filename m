From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [3/7] [CRYPTO] api: Split out low-level API
Date: Sat, 5 Aug 2006 20:06:52 +1000
Message-ID: <20060805100652.GA20939@gondor.apana.org.au>
References: <20060804133157.GA12787@gondor.apana.org.au> <20060804133426.GB12832@gondor.apana.org.au> <20060805.014958.26300600.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33292 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1422791AbWHEKG7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 06:06:59 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060805.014958.26300600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 05, 2006 at 01:49:58AM -0700, David Miller wrote:
>
> >  config CRYPTO_MANAGER
> >  	tristate "Cryptographic algorithm manager"
> > -	depends on CRYPTO
> > +	select CRYPTO_LOWAPI
> >  	default m
> >  	help
> >  	  Create default cryptographic template instantiations such as
> 
> There is no CRYPTO_MANAGER in my net-2.6.19 tree.
> 
> Are you patching against -mm or something like that?

Sorry Dave, these patches weren't meant for the net-2.6.19 tree.
They were supposed to enter -mm via the cryptodev tree.

I was just posting them for review.  I should've made that clearer
at the start.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
