From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [NETLINK] Remove netlink_sock_nr
Date: Wed, 27 Oct 2004 14:17:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027.141738.132559035.yoshfuji@linux-ipv6.org>
References: <20041027051107.GA8784@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au, davem@davemloft.net
In-Reply-To: <20041027051107.GA8784@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20041027051107.GA8784@gondor.apana.org.au> (at Wed, 27 Oct 2004 15:11:07 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> This patch removes netlink_sock_nr which is only used by a printk
> statement in af_netlink.c.  Even that's only there if
> NETLINK_REFCNT_DEBUG is defined.
> 
> If we were really looking for netlink refcnt bugs there are probably
> better places to do that anyway.

Alternatively, how about enclosing them with NETLINK_REFCNT_DEBUG
for future reference?

--yoshfuji
