From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: CCM/GCM implementation defect
Date: Fri, 24 Apr 2015 07:12:55 +0800
Message-ID: <20150423231255.GA26635@gondor.apana.org.au>
References: <20150423032619.GA17648@gondor.apana.org.au>
 <20150423114533.GI8928@secunet.com>
 <1429795499.31437.9.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Paul Wouters <pwouters@redhat.com>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
To: Martin Willi <martin@strongswan.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1429795499.31437.9.camel@martin>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 03:24:59PM +0200, Martin Willi wrote:
>
> Do you have any pointer for me where this is defined? Why is it needed,
> given that GCM implicitly authenticates the IV by using it in Y0?

The IV if present must be covered by the ICV.  This is required
by RFC4303 (section 2).  But really it's quite obvious.  If you
don't authenticate the IV, then I can easily inject random crap
into your network by changing the IV.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
