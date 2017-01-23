From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] Documentation: net: phy: improve explanation when to
 specify the PHY ID
Date: Mon, 23 Jan 2017 14:32:27 -0600
Message-ID: <20170123203227.etk23xwiqs7rzktt@rob-hp-laptop>
References: <20170122164132.13967-1-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andrew-g2DYL2Zd6BY@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org
To: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170122164132.13967-1-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 22, 2017 at 05:41:32PM +0100, Martin Blumenstingl wrote:
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
> 
> 
>  Documentation/devicetree/bindings/net/phy.txt | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
