From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Tue, 7 Jun 2005 09:20:09 +1000
Message-ID: <20050606232009.GA7475@gondor.apana.org.au>
References: <20050606230437.GA7172@gondor.apana.org.au> <20050606.160947.75190168.davem@davemloft.net> <20050606231405.GA7385@gondor.apana.org.au> <20050606.161814.130845728.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hch@infradead.org, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050606.161814.130845728.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 04:18:14PM -0700, David S. Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 7 Jun 2005 09:14:05 +1000
> 
> > 1) We use it directly as a scratch buffer for now since the
> > frags are always linearised currently.
> 
> And since skb_shinfo(skb)->nr_frags will be zero, nobody
> will mistakedly look at the contents and interpret it as
> some valid frags.  Right?

Yep.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
