From: David Miller <davem@davemloft.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
 `usbnet_set_settings':
Date: Mon, 19 Nov 2007 21:26:39 -0800 (PST)
Message-ID: <20071119.212639.217993660.davem@davemloft.net>
References: <200711071434.52607.david-b@pacbell.net>
	<20071107225232.GB26163@stusta.de>
	<20071108033010.GF26163@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, randy.dunlap@oracle.com,
	toralf.foerster@gmx.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758412AbXKTF0x@vger.kernel.org>
In-Reply-To: <20071108033010.GF26163@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Thu, 8 Nov 2007 04:30:10 +0100

> @davem:
> 
> Please look at net/ipv4/arp.c:arp_process()
> 
> Am I right that CONFIG_NET_ETHERNET=n and CONFIG_NETDEV_1000=y or 
> CONFIG_NETDEV_10000=y will not be handled correctly there?
> 
> And the best solution is to nuke all #ifdef's in this function and make 
> the code unconditionally available?

I think removing those specific ifdefs in arp_process()
is the best option, yes.
