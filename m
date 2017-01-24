From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] Documentation: net: phy: improve explanation when to
 specify the PHY ID
Date: Tue, 24 Jan 2017 13:31:19 -0500 (EST)
Message-ID: <20170124.133119.1062219188232552549.davem@davemloft.net>
References: <20170122164132.13967-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170122164132.13967-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Date: Sun, 22 Jan 2017 17:41:32 +0100

> The old description basically read like "ethernet-phy-idAAAA.BBBB" can
> be specified when you know the actual PHY ID. However, specifying this
> has a side-effect: it forces Linux to bind to a certain PHY driver (the
> one that matches the ID given in the compatible string), ignoring the ID
> which is reported by the actual PHY.
> Whenever a device is shipped with (multiple) different PHYs during it's
> production lifetime then explicitly specifying
> "ethernet-phy-idAAAA.BBBB" could break certain revisions of that device.
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> ---
> Thanks to Andrew Lunn for pointing the documentation issue out to me in:
> http://lists.infradead.org/pipermail/linux-amlogic/2017-January/002141.html

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
