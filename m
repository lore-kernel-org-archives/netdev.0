From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NETLINK] netlink_ack takes gfp flag as parameter
Date: Fri, 24 Sep 2004 12:12:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CAfZv-0001XB-00@gondolin.me.apana.org.au>
References: <41537473.1090306@eurodev.net>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pablo@eurodev.net (Pablo Neira)
In-Reply-To: <41537473.1090306@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira <pablo@eurodev.net> wrote:
> 
> AFAIK ip_queue, ip6_queue and dn_rtmsg use netlink_ack in interrupt 
> context which calls alloc_skb with the GFP_KERNEL flag. This patch adds 
> a new parameter to netlink_ack to set the gfp flag.

Bogus.  All of those functions call netlink_ack in the context of the
sending process.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
