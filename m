From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 18:03:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040725080347.GA20251@gondor.apana.org.au>
References: <20040724083709.GA9416@gondor.apana.org.au> <200407250410.03741.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <200407250410.03741.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jul 25, 2004 at 04:10:03AM +0900, Kazunori Miyazawa wrote:
> 
> To process routing header correctly, we should fix the codes which
> calls ip6_dst_lookup in ipv6 because there is difference of destinatio 
> addresses for routing resolution and looking up xfrm_policy.

What do you mean? Isn't the code in icmp.c/raw.c/tcp_ipv6.c/udp.c
that sets fl.fl6_dst using opt->srcrt enough?

If not then we'll need to change IPv4 as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
