From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6 tunnel stops accepting input
Date: Wed, 12 Jan 2005 07:36:37 +1100
Message-ID: <E1CoSkn-00058Z-00@gondolin.me.apana.org.au>
References: <20050111125826.GA25169@wiggy.net>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: wichert@wiggy.net (Wichert Akkerman)
In-Reply-To: <20050111125826.GA25169@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wichert Akkerman <wichert@wiggy.net> wrote:
> 
> but once I do a ping6 from my machine to the outside world:
> 
> 13:39:53.264393 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 1
> 13:39:53.299071 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 1
> 
> the tunnel suddenly accepts incoming traffic:

Do you have any netfilter rules?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
