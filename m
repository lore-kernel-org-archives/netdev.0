From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Tue, 7 Jun 2005 09:04:37 +1000
Message-ID: <20050606230437.GA7172@gondor.apana.org.au>
References: <20050606115939.GA399@gondor.apana.org.au> <20050606120914.GA8317@infradead.org> <20050606124043.GA625@gondor.apana.org.au> <20050606.154653.64001264.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050606.154653.64001264.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 03:46:53PM -0700, David S. Miller wrote:
> 
> So I guess I'm taking you a step backwards, I want to make
> skb_frag_struct a little bigger :-)  Ie. put the DMA mapping
> cookies into the skb_frag_struct, then a set of accessor
> macros like we have for scatterlist.  Well, in fact, it would
> become a scatterlist and therefore the only thing special
> about dma_map_skb() is that is maps a linear buffer via
> skb->data then the scatterlist in skb_shared_info(skb).

Bigger is better actually :) I'm now thinking of using the
memory occupied by the frags array for IPsec crypto operations.
So if it's bigger then it simply means that we can store more
fragments.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
