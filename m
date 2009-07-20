From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH 2/7] crypto: authenc - convert to ahash
Date: Mon, 20 Jul 2009 16:50:04 +0800
Message-ID: <20090720085004.GA5018@gondor.apana.org.au>
References: <20090716111548.GP20288@secunet.com> <20090716111747.GR20288@secunet.com> <20090717.100334.160030992.davem@davemloft.net> <20090720062643.GA20288@secunet.com> <20090720065514.GB4026@gondor.apana.org.au> <20090720075701.GC20288@secunet.com> <20090720082116.GA4797@gondor.apana.org.au> <20090720083640.GD20288@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090720083640.GD20288@secunet.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 20, 2009 at 10:36:40AM +0200, Steffen Klassert wrote:
> 
> For the crypto-layer it's just scatterwalk_sg_chain() that removes the
> termination bit. 

The history behind this is that the crypto layer has used chaining
way before generic chaining was invented.  When the generic code
was added I tried to convert crypto over to that, however, that
failed because generic chaining was not ported to every architecture.

So that's why the crypto layer still retains its own chaining.

> For the block-layer it's blk_rq_map_integrity_sg() and two times in
> blk_rq_map_sg().

I suppose we should ask Jens whether he thinks this is worth adding
an interface over?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
