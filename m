From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [5/6]: Dynamic neigh hash table growth
Date: Mon, 27 Sep 2004 21:33:34 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CBtl8-0000w8-00@gondolin.me.apana.org.au>
References: <20040923225127.10b0ef68.davem@davemloft.net>
Cc: laforge@gnumonks.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20040923225127.10b0ef68.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
>
> +static void neigh_hash_grow(struct neigh_table *tbl, unsigned long new_entries)
> +{
> +       struct neighbour **new_hash, **old_hash;
> +       unsigned int i, new_hash_mask, old_entries;
> +
> +       BUG_ON(new_entries & (new_entries - 1));
> +       new_hash = neigh_hash_alloc(new_entries);

Perhaps it'd be better to bound it based on MAX_ORDER rather than waiting
for neigh_hash_alloc() to fail?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
