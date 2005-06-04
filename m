From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 14:51:19 +1000
Message-ID: <20050604045119.GA25270@gondor.apana.org.au>
References: <20050604004201.GB20471@gondor.apana.org.au> <Xine.LNX.4.44.0506040039190.11329-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0506040039190.11329-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 12:39:41AM -0400, James Morris wrote:
> On Sat, 4 Jun 2005, Herbert Xu wrote:
> 
> > So this is really a sort of bio_vec for crypto structures.  The objective
> > here is to make the structure as compact as possible to allow users to
> > allocate it on the stack most of the time.
> 
> Seems like a good idea to me.

Thanks James.  What do you think about eating up 32 bytes on the
stack in esp_input/esp_output?

In fact, how did we come up with the number of four frags? Why wouldn't
say two frags do for most users or perhaps even one?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
