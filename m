From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] phy: remove documentation of removed member addr of
 phy_device structure
Date: Thu, 3 Mar 2016 16:14:19 +0100
Message-ID: <20160303151419.GK15541@lunn.ch>
References: <1457010748-2584-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48784 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752348AbcCCPOV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 10:14:21 -0500
Content-Disposition: inline
In-Reply-To: <1457010748-2584-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 02:12:28PM +0100, LABBE Corentin wrote:
> Commit e5a03bfd873c ("phy: Add an mdio_device structure") removed
> the addr member of the phy_device structure.
> This patch remove the documentation about that member.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Hi Corentin

The patch also removed bus and dev which are documented.  Could you
please expand you patch to remove those as well?

Thanks
	Andrew

> ---
>  include/linux/phy.h | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index d6f3641..e14569e 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -338,7 +338,6 @@ struct phy_c45_device_ids {
>   * suspended: Set to true if this phy has been suspended successfully.
>   * state: state of the PHY for management purposes
>   * dev_flags: Device-specific flags used by the PHY driver.
> - * addr: Bus address of PHY
>   * link_timeout: The number of timer firings to wait before the
>   * giving up on the current attempt at acquiring a link
>   * irq: IRQ number of the PHY's interrupt (-1 if none)
> -- 
> 2.4.10
> 
