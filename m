From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Assertions when lowering tcp_tso_win_divisor
Date: Wed, 17 Nov 2004 07:59:18 +1100
Message-ID: <E1CUAQ2-0002jT-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com (Sridhar Samudrala)
In-Reply-To: <Pine.LNX.4.58.0411160931080.31882@w-sridhar.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sridhar Samudrala <sri@us.ibm.com> wrote:
> We are seeing following assertions when running specweb99 with
> tcp_tso_win_divisor lowered to 4, 2 or 1 on linux 2.6.9 based kernels.

2.6.9 is known to have bugs in TCP book-keeping.  Please try 2.6.10-rc2
instead.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
