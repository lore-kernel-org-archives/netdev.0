From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Wed, 06 Apr 2005 12:45:58 +1000
Message-ID: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
References: <1112730889.16753.17.camel@beastie>
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: dmitry_yus@yahoo.com (Dmitry Yusupov)
In-Reply-To: <1112730889.16753.17.camel@beastie>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dmitry Yusupov <dmitry_yus@yahoo.com> wrote:
> 
> * new event for unicast connections NETLINK_UESTABLISHED.

Huh? In the patch you're actually sending the notification
when the socket stops listening to multicast traffic.

Please document why we need this in greater detail too.

> * netlink alloc_skb() now uses sk_allocation instead of hard-coded
> GFP_KERNEL

Why? We never set it to anything else for netlink.

> * since netlink event described via proto and pid,
> netlink_getsockbypid() is exported, so netlink user can identify socket.

Please submit the users for kernel inclusion first.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
