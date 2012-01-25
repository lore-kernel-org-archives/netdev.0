From: David Miller <davem@davemloft.net>
Subject: Re: [patch v3, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Tue, 24 Jan 2012 23:03:54 -0500 (EST)
Message-ID: <20120124.230354.1696063062900108959.davem@davemloft.net>
References: <12446987.2261327416407141.JavaMail.root@5-MeO-DMT.ynet.sk>
	<25119746.2341327416953583.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <25119746.2341327416953583.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Tue, 24 Jan 2012 15:55:53 +0100 (CET)

> diff -uprN -X linux/Documentation/dontdiff linux-3.2.1-orig/net/core/rtnetlink.c linux/net/core/rtnetlink.c
> --- linux-3.2.1-orig/net/core/rtnetlink.c	2012-01-12 20:42:45.000000000 +0100
> +++ linux/net/core/rtnetlink.c	2012-01-24 14:26:58.083219352 +0100
> @@ -1506,6 +1506,9 @@ errout:
>  
>  	if (send_addr_notify)
>  		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> +	min_ifinfo_dump_size = max_t(u16, if_nlmsg_size(dev),
> +					min_ifinfo_dump_size);
> +

What is this?  And whatever it is why isn't it 1) described in the
commit message and why isn't it 2) in a seperate patch if it's
unrelated to this macvlan change?

I'm not apply this patch as it is right now, it needs some sort of
change.
