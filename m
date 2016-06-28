From: "George Spelvin" <linux@sciencehorizons.net>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack crash, etc)
Date: 28 Jun 2016 10:32:12 -0400
Message-ID: <20160628143212.17215.qmail@ns.sciencehorizons.net>
References: <20160628133050.GA18468@gondor.apana.org.au>
Cc: linux-bluetooth@vger.kernel.org, linux-crypto@vger.kernel.org,
	luto@amacapital.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au, linux@sciencehorizons.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20160628133050.GA18468@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We have actually gained quite a bit of documentation recently.
> Have you looked at Documentation/DocBook/crypto-API.tmpl?
> 
> More is always welcome of course.

It's improved since I last looked at it, but there are still many structures
that aren't described:

- struct crypto_instance
- struct crypto_spawn
- struct crypto_blkcipher
- struct blkcipher_desc
- More on the context structures returned by crypto_tfm_ctx

Also not mentioned in the documentation is that some algorithms *do*
have different implementations depending on key size.  SHA-2 is the
classic example.
