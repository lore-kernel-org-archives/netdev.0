From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] macb: convert platform data phy_irq_pin to an int
Date: Thu, 24 Nov 2011 11:47:50 +0100
Message-ID: <4ECE20D6.1080409@atmel.com>
References: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: Jamie Iles <jamie@jamieiles.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from newsmtp5.atmel.com ([204.2.163.5]:55598 "EHLO
	sjogate2.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382Ab1KXKrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2011 05:47:55 -0500
In-Reply-To: <1322128098-17724-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2011 10:48 AM, Jamie Iles :
> AT91 platforms have been updated to set the phy_irq_pin to -EINVAL if
> not present, but phy_irq_pin is currently a u8.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> Signed-off-by: Jamie Iles <jamie@jamieiles.com>
> ---
>  include/linux/platform_data/macb.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/platform_data/macb.h b/include/linux/platform_data/macb.h
> index e7c748f..b081c72 100644
> --- a/include/linux/platform_data/macb.h
> +++ b/include/linux/platform_data/macb.h
> @@ -10,7 +10,7 @@
>  
>  struct macb_platform_data {
>  	u32		phy_mask;
> -	u8		phy_irq_pin;	/* PHY IRQ */
> +	int		phy_irq_pin;	/* PHY IRQ */
>  	u8		is_rmii;	/* using RMII interface? */
>  };
>  


-- 
Nicolas Ferre
