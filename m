From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Fri, 17 Sep 2004 23:11:26 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C8IWM-0005Ey-00@gondolin.me.apana.org.au>
References: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> 
> ChangeSet@1.1926, 2004-09-17 20:13:43+09:00, yoshfuji@linux-ipv6.org
> [XFRM] make xfrm_lookup() fully af-independent.
> 
> This extracts af-dependent portion from xfrm_lookup() 
> and put it into net/ipv4/route.c:ip_route_output_flow(),
> the user of xfrm_lookup() in IPv4 side.

This one looks great.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
