From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Mon, 20 Sep 2004 13:14:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1C9Edi-00033O-00@gondolin.me.apana.org.au>
References: <1095640781.1047.168.camel@jzny.localdomain>
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095640781.1047.168.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> wrote:
> 
> --- a/net/ipv4/fib_hash.c       2004/09/20 00:35:16     1.1
> +++ b/net/ipv4/fib_hash.c       2004/09/20 00:36:16
> @@ -915,7 +915,7 @@
>             iter->zone = iter->zone->fz_next) {
>                int maxslot;
> 
> -               if (!iter->zone->fz_next)
> +               if (!iter->zone->fz_nent)
>                        continue;

Good catch.  There seems to be another problem with the seq_file
conversion.  Why is this check only in fib_get_first(), but not
in fib_get_next()?

Either it's needed in fib_get_next() as well, or it can be removed here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
