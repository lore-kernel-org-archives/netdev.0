From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPv4]: More fib_alias insertion fixes
Date: Mon, 27 Sep 2004 07:23:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBgUG-0001GH-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.58.0409261611230.8973@u.domain.uli>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ja@ssi.bg (Julian Anastasov)
In-Reply-To: <Pine.LNX.4.58.0409261611230.8973@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov <ja@ssi.bg> wrote:
> 
>        True, but in your patch2 you return fa after
> list_for_each_entry which is not valid when the loop terminates.
> Just change it to return the fa into the loop.

You're right, we dereference it in fn_hash_insert.

> [-- text/plain, encoding base64, charset: US-ASCII, 28 lines, name: fib_ins3.diff --]
> [-- Description: fib_alias ordered by TOS --]
> 
> diff -ur v2.6.9-rc2-bk10/linux/net/ipv4/fib_hash.c linux/net/ipv4/fib_hash.c
> --- v2.6.9-rc2-bk10/linux/net/ipv4/fib_hash.c   2004-09-26 16:52:11.000000000 +0300

Looks good.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
