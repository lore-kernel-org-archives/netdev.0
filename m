From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH 2/7] IBM Akebono: Add support for a new PHY interface
 to the IBM emac driver
Date: Fri, 21 Feb 2014 11:18:23 +0000
Message-ID: <20140221111823.GA8783@e106331-lin.cambridge.arm.com>
References: <1392964293-13687-1-git-send-email-alistair@popple.id.au>
 <1392964293-13687-3-git-send-email-alistair@popple.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1392964293-13687-3-git-send-email-alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 21, 2014 at 06:31:28AM +0000, Alistair Popple wrote:
> The IBM PPC476GTR SoC that is used on the Akebono board uses a
> different ethernet PHY interface that has wake on lan (WOL) support
> with the IBM emac. This patch adds support to the IBM emac driver for
> this new PHY interface.
> 
> At this stage the wake on lan functionality has not been implemented.
> 
> Signed-off-by: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
> Acked-by: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> ---

[...]

> +       /* Check for RGMII flags */
> +       if (of_get_property(ofdev->dev.of_node, "has-mdio", NULL))
> +               dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;

You can use of_property_read_bool here.

Cheers,
Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
