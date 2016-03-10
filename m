From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] phy: remove documentation of removed members of
 phy_device structure
Date: Thu, 10 Mar 2016 15:21:56 +0100
Message-ID: <20160310142156.GE20539@lunn.ch>
References: <1457614738-17337-1-git-send-email-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LABBE Corentin <clabbe.montjoie@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457614738-17337-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2016 at 01:58:58PM +0100, LABBE Corentin wrote:
> Commit e5a03bfd873c ("phy: Add an mdio_device structure") removed addr,
> bus and dev member of the phy_device structure.
> This patch remove the documentation about those members.
> 
> Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Hi Corentin

Thanks for updating the patch with the extra removals.

       Andrew

> ---
>  include/linux/phy.h | 3 ---
>  1 file changed, 3 deletions(-)
> 
> Changes since v1
> - remove also documentation for dev and bus
> 
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index d6f3641..2abd791 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -327,8 +327,6 @@ struct phy_c45_device_ids {
>  /* phy_device: An instance of a PHY
>   *
>   * drv: Pointer to the driver for this PHY instance
> - * bus: Pointer to the bus this PHY is on
> - * dev: driver model device structure for this PHY
>   * phy_id: UID for this device found during discovery
>   * c45_ids: 802.3-c45 Device Identifers if is_c45.
>   * is_c45:  Set to true if this phy uses clause 45 addressing.
> @@ -338,7 +336,6 @@ struct phy_c45_device_ids {
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
