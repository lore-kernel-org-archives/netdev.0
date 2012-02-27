From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH] of/mdio: fix fixed link bus name
Date: Mon, 27 Feb 2012 09:59:38 -0600
Message-ID: <4F4BA86A.1040309@gmail.com>
References: <8ebe6a3f11343c392a7353581d5f648980206e8e.1330346765.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org, linuxppc-dev@lists.ozlabs.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36818 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab2B0P7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 10:59:41 -0500
Received: by ghrr11 with SMTP id r11so2054848ghr.19
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2012 07:59:41 -0800 (PST)
In-Reply-To: <8ebe6a3f11343c392a7353581d5f648980206e8e.1330346765.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2012 06:48 AM, Baruch Siach wrote:
> Since 9e6c643b (phy/fixed: use an unique MDIO bus name) the name of the fixed
> PHY bus is "fixed-0". Teach of_phy_connect_fixed_link() the new name.
> 

Applied for 3.3.

Rob

> Tested on a P1020RDB PowerPC system.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
>  drivers/of/of_mdio.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 980c079..483c0ad 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -182,7 +182,7 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
>  	if (!phy_id || sz < sizeof(*phy_id))
>  		return NULL;
>  
> -	sprintf(bus_id, PHY_ID_FMT, "0", be32_to_cpu(phy_id[0]));
> +	sprintf(bus_id, PHY_ID_FMT, "fixed-0", be32_to_cpu(phy_id[0]));
>  
>  	phy = phy_connect(dev, bus_id, hndlr, 0, iface);
>  	return IS_ERR(phy) ? NULL : phy;
