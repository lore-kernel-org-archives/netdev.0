From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 20:22:04 +1000
Message-ID: <20050604102204.GA1214@gondor.apana.org.au>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604135535.3cfb631f@zanzibar.2ka.mipt.ru> <20050604095854.GA1003@gondor.apana.org.au> <20050604141731.37479347@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20050604141731.37479347@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 02:17:31PM +0400, Evgeniy Polyakov wrote:
>
> Static scaterlists are not used and new are dinamically allocated.

That's precisely why we're having this discussion.  We can now
encrypt/decrypt a 1500 byte packet in 2us so the last thing we
want is to impose additional latencies on the common case unless
it's absolutely required.

If we can shrink the structure used between IPsec and the crypto
layer then we can allocate the sgbuf off the stack for 99% of
the users.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
