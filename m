From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] phy: fix kernel-doc notation
Date: Tue, 29 Apr 2008 01:59:01 -0400
Message-ID: <4816B925.6000103@pobox.com>
References: <Pine.LNX.4.64.0804281056520.30172@shark.he.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53360 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560AbYD2F7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:59:04 -0400
In-Reply-To: <Pine.LNX.4.64.0804281056520.30172@shark.he.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy.Dunlap wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix kernel-doc warning:
> Warning(linux-2.6.25-git11//drivers/net/phy/phy_device.c:275): No description found for parameter 'bus_id'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> ---
>  drivers/net/phy/phy_device.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-2.6.25-git11.orig/drivers/net/phy/phy_device.c
> +++ linux-2.6.25-git11/drivers/net/phy/phy_device.c
> @@ -256,7 +256,7 @@ void phy_prepare_link(struct phy_device 
>  /**
>   * phy_connect - connect an ethernet device to a PHY device
>   * @dev: the network device to connect
> - * @phy_id: the PHY device to connect
> + * @bus_id: the id string of the PHY device to connect
>   * @handler: callback function for state change notifications
>   * @flags: PHY device's dev_flags
>   * @interface: PHY device's interface

applied


