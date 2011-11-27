From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 4/8] bnx2x: Fix BCM84833 link and LED behavior
Date: Sun, 27 Nov 2011 17:01:48 -0500 (EST)
Message-ID: <20111127.170148.317907989262176377.davem@davemloft.net>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
	<1322417881-17760-5-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab1K0WBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:01:50 -0500
In-Reply-To: <1322417881-17760-5-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Sun, 27 Nov 2011 20:17:57 +0200

>  			/* Restart autoneg for 10G*/
>  
> +			bnx2x_cl45_read(bp, phy,
> +				MDIO_AN_DEVAD,
> +				MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
> +				&an_10g_val);
> +			bnx2x_cl45_write(bp, phy,
> +				MDIO_AN_DEVAD,
> +				MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
> +				an_10g_val | 0x1000);
>  			bnx2x_cl45_write(bp, phy,
>  				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL,
>  				 0x3200);

More bad formatting, make a helper function if you are worried
about 80 column limits.
