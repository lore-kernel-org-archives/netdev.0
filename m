From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC] [PATCH 2/7] crypto: authenc - convert to ahash
Date: Mon, 20 Jul 2009 10:36:40 +0200
Message-ID: <20090720083640.GD20288@secunet.com>
References: <20090716111548.GP20288@secunet.com> <20090716111747.GR20288@secunet.com> <20090717.100334.160030992.davem@davemloft.net> <20090720062643.GA20288@secunet.com> <20090720065514.GB4026@gondor.apana.org.au> <20090720075701.GC20288@secunet.com> <20090720082116.GA4797@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-crypto@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090720082116.GA4797@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 20, 2009 at 04:21:16PM +0800, Herbert Xu wrote:
> 
> Can you point me to the existing code?
> 

For the crypto-layer it's just scatterwalk_sg_chain() that removes the
termination bit. 

For the block-layer it's blk_rq_map_integrity_sg() and two times in
blk_rq_map_sg().
