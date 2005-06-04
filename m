From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 15:33:48 +1000
Message-ID: <20050604053348.GA5877@gondor.apana.org.au>
References: <20050604045119.GA25270@gondor.apana.org.au> <Xine.LNX.4.44.0506040122210.11356-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@davemloft.net>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0506040122210.11356-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 01:23:55AM -0400, James Morris wrote:
> On Sat, 4 Jun 2005, Herbert Xu wrote:
> 
> > Thanks James.  What do you think about eating up 32 bytes on the
> > stack in esp_input/esp_output?
> 
> Sounds like a low price to pay, given the general overhead of ipsec.

I agree with you on the stack usage.  BTW, we can now pump 5Gb/s
through the Crypto API using a 1Ghz VIA CPU with the Padlock so
encryption is no longer necessarily the slowest piece along the
pipeline :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
