From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 21:52:30 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731115230.GA18537@gondor.apana.org.au>
References: <20040731083456.GA24761@outpost.ds9a.nl> <E1Bqr9r-0004av-00@gondolin.me.apana.org.au> <20040731112048.GA27893@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, jmorris@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040731112048.GA27893@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 31, 2004 at 01:20:49PM +0200, bert hubert wrote:
> 
> setsockopt(3, SOL_UDP, 100, [1], 4)     = 0

You chose NON_IKE.

> read(3, "\0\0\206\305\0\0\f\311\27\263\3379\313z\377T\310\6\25\217"..., 1024) = 104

This packet is NON_ESP, aka UDP_ENCAP_ESPINUDP.
 
> Any further ideas? 

Either change the receiving end to using NON_ESP or change the
sender to use NON_IKE.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
