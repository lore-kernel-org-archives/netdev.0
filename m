From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 5/5] crypto: make struct aead percpu data
Date: Mon, 1 Dec 2008 21:51:24 +0800
Message-ID: <20081201135124.GA22140@gondor.apana.org.au>
References: <20081201071614.GP476@secunet.com> <20081201072043.GU476@secunet.com> <20081201114000.GB20961@gondor.apana.org.au> <20081201133654.GC13998@secunet.com> <20081201134448.GA21939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	klassert@mathematik.tu-chemnitz.de,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081201134448.GA21939@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2008 at 09:44:48PM +0800, Herbert Xu wrote:
>
> If you could finish them for me I'd be most grateful :)

In case it isn't clear from the code, once we've converted all
the algorithms then we can start converting the existing users
across to the new interface.  In particular, authenc can be made
to use shash (or ahash) which would render the spinlock useless.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
