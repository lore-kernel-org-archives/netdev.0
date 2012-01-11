From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Wed, 11 Jan 2012 11:36:11 +1100
Message-ID: <20120111003611.GA12257@gondor.apana.org.au>
References: <20120111000040.GA3801@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120111000040.GA3801@p183.telecom.by>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 11, 2012 at 03:00:40AM +0300, Alexey Dobriyan wrote:
> commit f9e2bca6c22d75a289a349f869701214d63b5060
> aka "crypto: sha512 - Move message schedule W[80] to static percpu area"
> created global message schedule area.
> 
> If sha512_update will ever be entered twice, hilarity ensures.

Hmm, do you know why this happens? On the face of it this shouldn't
be possible as preemption is disabled.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
