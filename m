From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Set truesize in pskb_expand_head
Date: Tue, 28 Sep 2004 07:29:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927212953.GB7243@gondor.apana.org.au>
References: <20040924232053.GA7807@gondor.apana.org.au> <20040924163328.7597352c.davem@davemloft.net> <20040924233555.GA7962@gondor.apana.org.au> <20040924233713.GA8001@gondor.apana.org.au> <20040924164540.2d750572.davem@davemloft.net> <20040925000503.GA10873@gondor.apana.org.au> <20040927122700.4696e416.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040927122700.4696e416.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 12:27:00PM -0700, David S. Miller wrote:
> 
> Ok.. idea wise.  But, why are you subtracting 'delta' from
> skb->truesize?  That's the amount actually used not the
> amount trimmed by pskb_expand_head().

delta = skb->end - skb->tail which is the amount we want to trim.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
