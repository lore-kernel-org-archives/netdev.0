From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PPP-over-L2TP kernel support, new patch for review
Date: Wed, 22 Sep 2004 20:53:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CA4kn-0005jn-00@gondolin.me.apana.org.au>
References: <1095847092.41514cb435b7e@www.katalix.com>
Cc: bcrl@kvack.org, davem@davemloft.net, netdev@oss.sgi.com, kleptog@svana.org,
        mostrows@styx.uwaterloo.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: jchapman@katalix.com (James Chapman)
In-Reply-To: <1095847092.41514cb435b7e@www.katalix.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Chapman <jchapman@katalix.com> wrote:
> 
> The biggest difference in our approaches is that Martijn and I use a
> PPPoL2TP socket per session bound through a plain AF_INET UDP tunnel
> socket while Ben uses a new AF_L2TP tunnel socket and no separate
> socket per session. Both have their merits.

Can you elaborate on the merits of having a socket? It would seem to me
that not having a socket is a lot more scalable.  After all IPsec doesn't
carry a socket around per session.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
