From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [patch v1 1/2] dt-bindings: net: add binding documentation for
 mlxsw thermal control
Date: Tue, 29 Aug 2017 21:15:25 +0200
Message-ID: <20170829191525.GH8235@lunn.ch>
References: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
 <1504032311-195988-2-git-send-email-vadimp@mellanox.com>
 <20170829172254.GG8235@lunn.ch>
 <AM4PR05MB33300CC580ADD6CDABD13167A29F0@AM4PR05MB3330.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org" <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
        "ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AM4PR05MB33300CC580ADD6CDABD13167A29F0-n5Jp0YuYvM1LPiJj6BpYmdqRiQSDpxhJvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 05:57:01PM +0000, Vadim Pasternak wrote:
> 
> 
> > -----Original Message-----
> > From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> > Sent: Tuesday, August 29, 2017 8:23 PM
> > To: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org;
> > ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: Re: [patch v1 1/2] dt-bindings: net: add binding documentation for
> > mlxsw thermal control
> > 
> > > +- compatible		: "mellanox,mlxsw_minimal"
> > 
> > Interesting product name. Is there a mlxsw_maximal planned?
> > 
> 
> Hi Andrew,
> 
> Thank you very much for review.
> 
> No plans for such product. We just have fully functional drivers for different
> kind of Mellanox switch devices like spectrum, switchib, switchx2. All of them
> work over PCI bus. The minimal is supposed to be used for the chassis
> management and we uses it at BMC side. It works over I2C bus and doesn't
> depend on switch type. So it has a minaml functionality, so name "minimal".

That is not really how device tree compatible names work. The
compatible should be the product name, or the first product which had
this functionality. So in this case is the product is the chassis?
What name does the chassis have?

At some point, it would be good if you made the .dts file public. That
would give people a better idea how this all fits together.

> > I don't know much about the thermal subsystem. But looking at other
> > example binding documents, you seem to do something different here to
> > other drivers. Why do you not use what seems to be the common format:
> 
> In mlxsw_thermal driver we have definition for the thermal trips, which contains
> the type, like  "active" of "passive", temperature  in millicelsius and min/max states
> for cooling device. These vector defines thermal trip points.
> The hysteresis parameter is not relevant.

As i said, i don't know much about the thermal subsystem. So i cannot
comment on if your binding is good or bad. It just seems different,
which is often bad.

You really need the thermal subsystem guys to review this. But you
didn't Cc: them.

./scripts/get_maintainer.pl drivers/thermal/thermal_core.c 
Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> (supporter:THERMAL)
Eduardo Valentin <edubezval-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (supporter:THERMAL)
linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:THERMAL)

This driver has nothing to do with netdev. I'm wondering if it
actually belongs in drivers/thermal? Or maybe drivers/hwmon?
The pm and hwmon guys will probably tell you.

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
