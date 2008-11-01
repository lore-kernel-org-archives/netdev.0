From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Sat, 1 Nov 2008 13:04:58 +0800
Message-ID: <20081101050458.GA17807@gondor.apana.org.au>
References: <20081101043737.GA1621@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49581 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750716AbYKAFFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2008 01:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20081101043737.GA1621@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 01, 2008 at 07:37:37AM +0300, Alexey Dobriyan wrote:
> digest_null algorithm is now mandatory for ESP.
> 
> Steps to reproduce:
> 
> 	kernel with CONFIG_CRYPTO_NULL=n
> 
> 	#!/usr/sbin/setkey -f
> 	flush;
> 	spdflush;
> 	add 192.168.0.1 192.168.0.42 esp 15701 -E 3des-cbc "123456789012123456789012";

You do realise that this is totally insecure against man-in-the-
middle attacks, right?

We don't make ESP depend on every single algorithm out there.
It is the user's responsibility to turn on esoteric choices.
IMHO the use of encryption without authentication is definitely
non-standard.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
