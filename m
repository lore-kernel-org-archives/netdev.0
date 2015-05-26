From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 5/7] esp6: Switch to new AEAD interface
Date: Tue, 26 May 2015 15:38:59 +0800
Message-ID: <20150526073858.GA6634@gondor.apana.org.au>
References: <20150521103938.GA23035@gondor.apana.org.au>
 <2306681.gksi6E3i3N@tachyon.chronox.de>
 <20150526072152.GA6407@gondor.apana.org.au>
 <1712288.Rcrx4S4ED0@tauon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Stephan Mueller <smueller@chronox.de>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1712288.Rcrx4S4ED0@tauon>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 26, 2015 at 09:37:09AM +0200, Stephan Mueller wrote:
>
> - the current IKE implementations use rfc4106(gcm(aes)). They would need to 
> use seqniv(rfc4106(gcm(aes))) depending on the kernel version. So, we have a 
> clear change in the user space API where the old configuration even works 
> (i.e. no error), but does not produce the correct encryption that is required.

You mean through the user-space AEAD interface? That's not a problem
because I'm going to disable it for 4.1 :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
