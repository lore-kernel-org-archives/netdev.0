From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5 v2] Tsi108_eth: add missing linking to driver data
Date: Mon, 11 Feb 2008 11:40:17 -0500
Message-ID: <47B07A71.3060405@pobox.com>
References: <1B5F013528140F45B5C671039279CA5702A9638A@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Zang Roy-r61911 <tie-fei.zang@freescale.com>
To: Alexandre Bounine <Alexandre.Bounine@tundra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48733 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758660AbYBKQkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:40:22 -0500
In-Reply-To: <1B5F013528140F45B5C671039279CA5702A9638A@NANUK.pc.tundra.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexandre Bounine wrote:
> Bug fix for tsi108_eth network driver.
> This patch adds missing linking to driver data. 
>    
> Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
> ---
> 
> diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
> linux-2.6.24-fix/drivers/net/tsi108_eth.c
> --- linux-2.6.24/drivers/net/tsi108_eth.c	2008-01-24
> 17:58:37.000000000 -0500
> +++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
> 14:30:04.000000000 -0500
> @@ -1629,6 +1629,7 @@ tsi108_init_one(struct platform_device *
>  		goto register_fail;
>  	}
>  
> +	platform_set_drvdata(pdev, dev);
>  	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
>  	       dev->name, print_mac(mac, dev->dev_addr));
>  #ifdef DEBUG

still getting word-wrapped... even the patch header is mangled across 
multiple lines


