From: David Miller <davem@davemloft.net>
Subject: Re: [3/7] [CRYPTO] api: Split out low-level API
Date: Sat, 05 Aug 2006 01:49:58 -0700 (PDT)
Message-ID: <20060805.014958.26300600.davem@davemloft.net>
References: <20060804133157.GA12787@gondor.apana.org.au>
	<20060804133426.GB12832@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16320
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422769AbWHEItt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Aug 2006 04:49:49 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060804133426.GB12832@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 4 Aug 2006 23:34:26 +1000

> [CRYPTO] api: Split out low-level API
> 
> The crypto API is made up of the part facing users such as IPsec and the
> low-level part which is used by cryptographic entities such as algorithms.
> This patch splits out the latter so that the two APIs are more clearly
> delineated.  As a bonus the low-level API can now be modularised if all
> algorithms are built as modules.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This patch doesn't apply:

>  config CRYPTO_MANAGER
>  	tristate "Cryptographic algorithm manager"
> -	depends on CRYPTO
> +	select CRYPTO_LOWAPI
>  	default m
>  	help
>  	  Create default cryptographic template instantiations such as

There is no CRYPTO_MANAGER in my net-2.6.19 tree.

Are you patching against -mm or something like that?

I'm going to leave the rest of these patches until this
is resolved.
