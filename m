From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [RFC PATCH 02/17] of_mdio: Don't phy_scan_fixups() twice
Date: Tue, 25 Oct 2011 06:56:02 +0200
Message-ID: <20111025045602.GB798@ponder.secretlab.ca>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
 <1319144425-15547-3-git-send-email-Kyle.D.Moffett@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1319144425-15547-3-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2011 at 05:00:09PM -0400, Kyle Moffett wrote:
> The "phy_device_register()" call 5 lines down already calls
> phy_scan_fixups(), there's no need to do it a second time.
> 
> Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>

Applied, thanks.

g.

> ---
>  drivers/of/of_mdio.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index d35e300..980c079 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -83,7 +83,6 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  				addr);
>  			continue;
>  		}
> -		phy_scan_fixups(phy);
>  
>  		/* Associate the OF node with the device structure so it
>  		 * can be looked up later */
> -- 
> 1.7.2.5
> 
