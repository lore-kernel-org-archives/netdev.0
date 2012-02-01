From: David Miller <davem@davemloft.net>
Subject: Re: [patch v7, kernel version 3.2.1] Source mode for macvlan
 interface
Date: Wed, 01 Feb 2012 14:34:55 -0500 (EST)
Message-ID: <20120201.143455.1014458821077044311.davem@davemloft.net>
References: <21672990.651327923923151.JavaMail.root@5-MeO-DMT.ynet.sk>
	<13688762.701327924297781.JavaMail.root@5-MeO-DMT.ynet.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: steweg@ynet.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <13688762.701327924297781.JavaMail.root@5-MeO-DMT.ynet.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Gula <steweg@ynet.sk>
Date: Mon, 30 Jan 2012 12:51:37 +0100 (CET)

> V6 changes:
>  - removed ability to fill the list of macaddr per link to fix the
>    issue of netlink skb size. This can be added back by using separate
>    netlink dumper in kernel and parse inside iproute2 codes. Those codes
>    are beyond my abilities so if anyone actually need that feel free to 
>    help.

I'm not applying this patch until you add an appropriate way to query
the setting, working around the link dump SKB size issue by not providing
a way to query the information at all is not acceptable.
