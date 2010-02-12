From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/7] Add netdev_printk and netif_printk
 macros
Date: Fri, 12 Feb 2010 12:31:29 -0800 (PST)
Message-ID: <20100212.123129.163263355.davem@davemloft.net>
References: <cover.1265751023.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35840
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757722Ab0BLUbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:31:14 -0500
In-Reply-To: <cover.1265751023.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue,  9 Feb 2010 13:49:46 -0800

> Some logging messages duplicate the driver name with the device name like:
> 
> ATL1E 0000:03:00.0: ATL1E: eth0 NIC Link is Up<100 Mbps Full Duplex>
>  
> Some drivers/net/... have created netif_ macros like:
> 
> drivers/net/sis190.c:#define net_drv(p, arg...)		if (netif_msg_drv(p)) \
> drivers/net/sis190.c-					printk(arg)
> drivers/net/sis190.c:#define net_probe(p, arg...)	if (netif_msg_probe(p)) \
> drivers/net/sis190.c-					printk(arg)
> drivers/net/sis190.c:#define net_link(p, arg...)	if (netif_msg_link(p)) \
> drivers/net/sis190.c-					printk(arg)
> drivers/net/sis190.c:#define net_intr(p, arg...)	if (netif_msg_intr(p)) \
> drivers/net/sis190.c-					printk(arg)
> drivers/net/sis190.c:#define net_tx_err(p, arg...)	if (netif_msg_tx_err(p)) \
> drivers/net/sis190.c-					printk(arg)
> 
> This RFC patch creates a set of these macros to standardize
> the coding and logging style of struct net_device and netif_msg macros
> 
> I think they're useful, might be mindless churn to others.
> 
> The atl1e change reduces log duplicate names.
> 
> The qlge change is an example of what be mindless churn for standardization
> sake, the r8169, jme, and skge are more reasonable.
> 
> Comments?

I really like these changes, feel free to make a pass of niu.[ch] making it
use these things :-)

All applied to net-next-2.6, thanks!
