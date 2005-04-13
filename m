From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about connect and ipsec
Date: Wed, 13 Apr 2005 13:50:32 +1000
Message-ID: <E1DLYtc-0002WL-00@gondolin.me.apana.org.au>
References: <1113314992.9028.18.camel@bguo.bluesocket.com>
Cc: netdev@oss.sgi.com, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: bguo@bluesocket.com (Bin Guo)
In-Reply-To: <1113314992.9028.18.camel@bguo.bluesocket.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bin Guo <bguo@bluesocket.com> wrote:
> 
> The connect call seems to map directly to net/ipv4/datagram.c:
> ip4_datagram_connect. Is it true that connect call on udp sockets
> result in SA creation and temporary failure? Is it by design just
> checking route to a destination protected ipsec will trigger SA
> creation?

It is a deficiency in the current implementation.  This problem
will be solved along with others in the xfrm resolution stuff that
Patrick McHardy is working on.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
