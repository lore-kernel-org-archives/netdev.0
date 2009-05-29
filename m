From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] mac8390: fix build with NET_POLL_CONTROLLER
Date: Fri, 29 May 2009 14:03:58 +0200
Message-ID: <20090529120357.GC3492@psychotron.englab.brq.redhat.com>
References: <Pine.LNX.4.64.0905281454450.9036@loopy.telegraphics.com.au> <20090527.223355.118242797.davem@davemloft.net> <Pine.LNX.4.64.0905282200460.12066@loopy.telegraphics.com.au> <20090529.015608.21828664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fthain@telegraphics.com.au, netdev@vger.kernel.org,
	linux-m68k@vger.kernel.org, geert.uytterhoeven@gmail.com,
	shemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090529.015608.21828664.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, May 29, 2009 at 10:56:08AM CEST, davem@davemloft.net wrote:
>From: Finn Thain <fthain@telegraphics.com.au>
>Date: Thu, 28 May 2009 22:05:53 +1000 (EST)
>
>> --- linux-2.6.29.orig/drivers/net/Makefile	2009-05-28 15:15:13.000000000 +1000
>> +++ linux-2.6.29/drivers/net/Makefile	2009-05-28 15:15:54.000000000 +1000
>> @@ -489,7 +489,7 @@
>>  	.ndo_set_mac_address 	= eth_mac_addr,
>>  	.ndo_change_mtu		= eth_change_mtu,
>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>> -	.ndo_poll_controller	= ei_poll,
>> +	.ndo_poll_controller	= __ei_poll,
>>  #endif
>>  };
>
>I don't think this is a patch to drivers/net/Makefile :-)
:)) Good one.. I wonder how this can happen ;)
>
>I've seen some patch screwups in my time, but this one
>takes the cake as one of the most impressive ones :-)
>
>I'll fix it up by hand, but realize that this makes more
>work for me.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
