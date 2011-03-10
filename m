From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH 2/8] macb: detect hclk presence from platform data
Date: Thu, 10 Mar 2011 11:45:19 +0000
Message-ID: <20110310114519.GD6198@pulham.picochip.com>
References: <1299751843-9743-1-git-send-email-jamie@jamieiles.com>
 <1299751843-9743-3-git-send-email-jamie@jamieiles.com>
 <20110310101554.GD11273@n2100.arm.linux.org.uk>
 <20110310114137.GC6198@pulham.picochip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	nicolas.ferre@atmel.com
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54084 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242Ab1CJLpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 06:45:22 -0500
Received: by wya21 with SMTP id 21so1351208wya.19
        for <netdev@vger.kernel.org>; Thu, 10 Mar 2011 03:45:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20110310114137.GC6198@pulham.picochip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 11:41:37AM +0000, Jamie Iles wrote:
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index bfd3601..8e6d8e3 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -246,9 +246,7 @@ static int macb_mii_init(struct macb *bp)
>  	bp->mii_bus->parent = &bp->dev->dev;
>  	pdata = bp->pdev->dev.platform_data;
>  
> -	if (pdata)
> -		bp->mii_bus->phy_mask = pdata->phy_mask;
> -
> +	bp->mii_bus->phy_mask = pdata->phy_mask;
>  	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
>  	if (!bp->mii_bus->irq) {
>  		err = -ENOMEM;

Doh, too hasty.  That hunk shouldn't be there now.  I'll fix that up for 
next time.

Jamie
