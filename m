From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: IPv6 badness continues
Date: Sat, 08 Jan 2005 12:24:22 -0500
Message-ID: <41E01746.3080501@pobox.com>
References: <41DA3A60.8050102@pobox.com> <20050108042509.GA1959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
        YOSHIFUJI Hideaki / ???????????? <yoshfuji@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050108042509.GA1959@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> ===== net/ipv6/route.c 1.102 vs edited =====
> --- 1.102/net/ipv6/route.c	2004-11-30 14:24:46 +11:00
> +++ edited/net/ipv6/route.c	2005-01-08 15:23:24 +11:00
> @@ -379,6 +379,7 @@
>  	int err;
>  
>  	write_lock_bh(&rt6_lock);
> +	WARN_ON(rt->u.dst->obsolete);
>  	err = fib6_add(&ip6_routing_table, rt, nlh, _rtattr);
>  	write_unlock_bh(&rt6_lock);

still broken:

net/ipv6/route.c: In function `ip6_ins_rt':
net/ipv6/route.c:382: error: invalid type argument of `->'
