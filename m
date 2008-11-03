From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Mon, 3 Nov 2008 09:04:31 +0800
Message-ID: <20081103010431.GA29905@gondor.apana.org.au>
References: <20081101050458.GA17807@gondor.apana.org.au> <20081101113835.GA3127@x200.localdomain> <20081101115043.GA19593@gondor.apana.org.au> <20081101.213315.01349801.davem@davemloft.net> <20081103001643.GA22217@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33046 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751174AbYKCBEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2008 20:04:38 -0500
Content-Disposition: inline
In-Reply-To: <20081103001643.GA22217@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 03, 2008 at 03:16:43AM +0300, Alexey Dobriyan wrote:
>
> Keep in mind that the only error message is "line N: returned (null)"
> from setkey(8) or something like that and no SA created.
> 
> It took me full printk session to realize what's going on.

As our error passing really sucks, I'm happy to accept a patch
to crypto_alloc_tfm which prints out a message if it fails.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
