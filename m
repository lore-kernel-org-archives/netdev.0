From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pppoe and receive checksum offload
Date: Mon, 28 Feb 2005 22:39:38 +1100
Message-ID: <20050228113938.GA3393@gondor.apana.org.au>
References: <20050224155906.73890361@dxpl.pdx.osdl.net> <20050228113106.GA3268@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, mostrows@speakeasy.net,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050228113106.GA3268@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2005 at 10:31:06PM +1100, herbert wrote:
> 
> In fact it looks like the current code in ip_gre is broken
> in this respect as well.

Actually ip_gre is probably right.  It seems that CHECKSUM_UNNECESSARY
should not be set for PPPOE/GRE packets at all.  So it would be a bug in
the sk* driver.

Alexey/Dave, is this interpretation of ip_summed correct?

Of course we still need to fix up CHECKSUM_HW in pppoe.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
