From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with IPSEC tunnel mode
Date: Thu, 21 Apr 2005 22:57:48 +1000
Message-ID: <E1DObFc-0000je-00@gondolin.me.apana.org.au>
References: <200504201737.51053.wolfgang.walter@studentenwerk.mhn.de>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: wolfgang.walter@studentenwerk.mhn.de (Wolfgang Walter)
In-Reply-To: <200504201737.51053.wolfgang.walter@studentenwerk.mhn.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de> wrote:
>
> 5. then it disappears (it is NOT dropped by iptables)
>   especially it is not seen in FORWARD (mangle-table).
> 
> The route to E on C is a host route via 10.148.15.10.

Please show us the output of "ip ru" and "ip ro".

> src 10.148.4.0/28 dst 10.0.25.210/32
>        dir in priority 2084
>        tmpl    src 192.168.9.237 dst 192.168.77.161
>                proto esp spi 0x00000000 reqid 16465 mode tunnel
> 
> src 10.148.4.0/28 dst 10.0.25.210/32
>        dir out priority 0
> 
> src 10.148.4.0/28 dst 10.0.25.210/32
>        dir fwd priority 2084
>        tmpl    src 192.168.9.237 dst 192.168.77.161
>                proto esp spi 0x00000000 reqid 16465 mode tunnel

Please attach the complete output of "ip x p".
 
> Interestingly, the original scenario works fine when we use kernel 2.6.7-rc1 
> instead of 2.6.11.7 and setkey from ipsec-tools 0.3.3. In this case there are 

What if you use the new ipsec-tools against the old kernel?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
