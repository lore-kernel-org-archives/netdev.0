From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phy layer: fix genphy_setup_forced (don't reset)
Date: Sat, 25 Aug 2007 00:40:43 -0400
Message-ID: <46CFB2CB.1040400@garzik.org>
References: <20070817065445.GH13994@moe.telargo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Domen Puncer <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42148 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761640AbXHYEkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:40:45 -0400
In-Reply-To: <20070817065445.GH13994@moe.telargo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Domen Puncer wrote:
> Writing BMCR_RESET bit will reset MII_BMCR to default values. This is
> clearly not what we want.
> 
> 
> Signed-off-by: Domen Puncer <domen.puncer@telargo.com>
> 
> ---
>  drivers/net/phy/phy_device.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: work-powerpc.git/drivers/net/phy/phy_device.c
> ===================================================================
> --- work-powerpc.git.orig/drivers/net/phy/phy_device.c
> +++ work-powerpc.git/drivers/net/phy/phy_device.c
> @@ -364,7 +364,7 @@ EXPORT_SYMBOL(genphy_config_advert);
>   */
>  int genphy_setup_forced(struct phy_device *phydev)
>  {
> -	int ctl = BMCR_RESET;
> +	int ctl = 0;
>  
>  	phydev->pause = phydev->asym_pause = 0;

applied


