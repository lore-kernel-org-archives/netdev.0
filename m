From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Transparent Proxying
Date: Wed, 4 Aug 2004 15:07:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040804050728.GA2968@gondor.apana.org.au>
References: <20040804032756.GA2388@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20040804032756.GA2388@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Aug 04, 2004 at 01:27:56PM +1000, herbert wrote:
>
> might be overcome.  If you know another way of getting the destination
> information then that would be good to (apart from the obvious one
> of parsing /proc/net/ip_conntrack :)

Never mind, I somehow missed getorigdst in ip_conntrack_core.c which
does exactly what I want.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
