From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: fix build with NET_POLL_CONTROLLER
Date: Fri, 29 May 2009 01:56:08 -0700 (PDT)
Message-ID: <20090529.015608.21828664.davem@davemloft.net>
References: <Pine.LNX.4.64.0905281454450.9036@loopy.telegraphics.com.au>
	<20090527.223355.118242797.davem@davemloft.net>
	<Pine.LNX.4.64.0905282200460.12066@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	geert.uytterhoeven@gmail.com, shemminger@vyatta.com
To: fthain@telegraphics.com.au
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0905282200460.12066@loopy.telegraphics.com.au>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Finn Thain <fthain@telegraphics.com.au>
Date: Thu, 28 May 2009 22:05:53 +1000 (EST)

> --- linux-2.6.29.orig/drivers/net/Makefile	2009-05-28 15:15:13.000000000 +1000
> +++ linux-2.6.29/drivers/net/Makefile	2009-05-28 15:15:54.000000000 +1000
> @@ -489,7 +489,7 @@
>  	.ndo_set_mac_address 	= eth_mac_addr,
>  	.ndo_change_mtu		= eth_change_mtu,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> -	.ndo_poll_controller	= ei_poll,
> +	.ndo_poll_controller	= __ei_poll,
>  #endif
>  };

I don't think this is a patch to drivers/net/Makefile :-)

I've seen some patch screwups in my time, but this one
takes the cake as one of the most impressive ones :-)

I'll fix it up by hand, but realize that this makes more
work for me.
