From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/4] skge: turn carrier off when down
Date: Wed, 11 Apr 2007 11:54:54 -0400
Message-ID: <461D04CE.7060004@pobox.com>
References: <20070407230224.486666854@linux-foundation.org> <20070407230325.470129283@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46871 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144AbXDKPy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2007 11:54:57 -0400
In-Reply-To: <20070407230325.470129283@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Driver needs to turn off carrier when down, otherwise it can
> confuse bonding and bridging and looks like carrier is on immediately
> when it is brought back up.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> --- netdev-2.6.orig/drivers/net/skge.c	2007-04-07 15:09:13.000000000 -0700
> +++ netdev-2.6/drivers/net/skge.c	2007-04-07 15:09:58.000000000 -0700
> @@ -2535,6 +2535,7 @@
>  		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);
>  
>  	netif_stop_queue(dev);
> +	netif_carrier_off(dev);
>  	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
>  		del_timer_sync(&skge->link_timer);
>  
> 


applied 1-4


