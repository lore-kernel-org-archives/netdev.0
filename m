From: Alistair Popple <alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org>
Subject: Re: [PATCH 2/7] IBM Akebono: Add support for a new PHY interface to the IBM emac driver
Date: Mon, 24 Feb 2014 13:09:19 +1100
Message-ID: <7545458.ltLKFumBkZ@mexican>
References: <1392964293-13687-1-git-send-email-alistair@popple.id.au> <1392964293-13687-3-git-send-email-alistair@popple.id.au> <20140221111823.GA8783@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140221111823.GA8783-NuALmloUBlrZROr8t4l/smS4ubULX0JqMm0uRHvK7Nw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Feb 2014 11:18:23 Mark Rutland wrote:
> On Fri, Feb 21, 2014 at 06:31:28AM +0000, Alistair Popple wrote:

[...]

> 
> > +       /* Check for RGMII flags */
> > +       if (of_get_property(ofdev->dev.of_node, "has-mdio", NULL))
> > +               dev->flags |= EMAC_RGMII_FLAG_HAS_MDIO;
> 
> You can use of_property_read_bool here.

Thanks. I will update it.

Regards,

Alistair

> 
> Cheers,
> Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
