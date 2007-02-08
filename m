From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] phy devices: use same arg types
Date: Thu, 8 Feb 2007 17:25:21 -0600
Message-ID: <C6CC76D5-233D-46A8-B0E9-02C22890067B@freescale.com>
References: <20070205104420.4970ab1e.randy.dunlap@oracle.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jgarzik <jgarzik@pobox.com>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:56675 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992447AbXBISbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 13:31:47 -0500
In-Reply-To: <20070205104420.4970ab1e.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 5, 2007, at 12:44, Randy Dunlap wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
>
> sparse complains about differing types from prototype to
> definition, so change the u32 to phy_interface_t:
>
> drivers/net/phy/phy_device.c:140:19: error: symbol 'phy_connect'  
> redeclared with different type (originally declared at include/ 
> linux/phy.h:362) - incompatible argument 5 (different signedness)
> drivers/net/phy/phy_device.c:190:19: error: symbol 'phy_attach'  
> redeclared with different type (originally declared at include/ 
> linux/phy.h:360) - incompatible argument 4 (different signedness)
>
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>


Acked-by: Andy Fleming <afleming@freescale.com>


Oops,  I thought I had fixed that before submission.


> ---
>  drivers/net/phy/phy_device.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> --- linux-2620-pv.orig/drivers/net/phy/phy_device.c
> +++ linux-2620-pv/drivers/net/phy/phy_device.c
> @@ -139,7 +139,7 @@ void phy_prepare_link(struct phy_device
>   */
>  struct phy_device * phy_connect(struct net_device *dev, const char  
> *phy_id,
>  		void (*handler)(struct net_device *), u32 flags,
> -		u32 interface)
> +		phy_interface_t interface)
>  {
>  	struct phy_device *phydev;
>
> @@ -188,7 +188,7 @@ static int phy_compare_id(struct device
>  }
>
>  struct phy_device *phy_attach(struct net_device *dev,
> -		const char *phy_id, u32 flags, u32 interface)
> +		const char *phy_id, u32 flags, phy_interface_t interface)
>  {
>  	struct bus_type *bus = &mdio_bus_type;
>  	struct phy_device *phydev;
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

