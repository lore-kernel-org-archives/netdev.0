From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack
 crash, etc)
Date: Wed, 29 Jun 2016 10:20:49 +0800
Message-ID: <20160629022049.GA23390@gondor.apana.org.au>
References: <20160628133050.GA18468@gondor.apana.org.au>
 <20160628143212.17215.qmail@ns.sciencehorizons.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth@vger.kernel.org, linux-crypto@vger.kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160628143212.17215.qmail@ns.sciencehorizons.net>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 28, 2016 at 10:32:12AM -0400, George Spelvin wrote:
> 
> - struct crypto_instance
> - struct crypto_spawn
> - struct crypto_blkcipher
> - struct blkcipher_desc
> - More on the context structures returned by crypto_tfm_ctx

blkcipher is obsolete and will be removed soon.  So if you are
going to write this then please document skcipher instead.

> Also not mentioned in the documentation is that some algorithms *do*
> have different implementations depending on key size.  SHA-2 is the
> classic example.

What do you mean by that? SHA has no keying at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
