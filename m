From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [5/*] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: Mon, 11 Apr 2005 07:28:48 +1000
Message-ID: <20050410212848.GB30337@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <20050409111551.GA7378@gondor.apana.org.au> <20050410074849.GA13259@gondor.apana.org.au> <20050410090250.GA26022@gondor.apana.org.au> <1113142510.1091.294.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113142510.1091.294.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Apr 10, 2005 at 10:15:11AM -0400, jamal wrote:
> 
> The main reason i did the XFRM_SAP_* is to be able to cover a case where
> a message was relevant to one KM but not the other. That may not
> exist now (actually it does with policy expiration that pfkey cant
> handle - but thats easy to take care of).
> Hopefully XFRM_MSG_xxx is the superset and will be sufficient.

Since xfrm_user is meant to be the native interface, this should never
happen.

> Do you have anymore patches? If not i can give these a quick test;
> Masahide has a better test setup and if he has time he should as well.

That's it for now.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
