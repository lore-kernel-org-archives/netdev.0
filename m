From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sat, 18 Jun 2011 10:26:55 -0600
Message-ID: <20110618162655.GK8195@ponder.secretlab.ca>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
	<1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
	<201106181821.46574.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Jason Liu <jason.hui-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeremy Kerr <jeremy.kerr-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <201106181821.46574.arnd-r2nGTMty4D4@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 06:21:46PM +0200, Arnd Bergmann wrote:
> On Saturday 18 June 2011 17:19:12 Shawn Guo wrote:
> >
> > +Required properties:
> > +- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
> > +- reg : address and length of the register set for the device
> > +- interrupts : should contain uart interrupt
> > +- id : should be the port ID defined by soc
> > +
> > +Optional properties:
> > +- fsl,has-rts-cts : indicate it has rts-cts
> > +- fsl,irda-mode : support irda mode
> > +
> > +Example:
> > +
> > +uart@73fbc000 {
> > +	compatible = "fsl,imx51-uart", "fsl,imx-uart";
> > +	reg = <0x73fbc000 0x4000>;
> > +	interrupts = <31>;
> > +	id = <1>;
> > +	fsl,has-rts-cts;
> > +};
> 
> Should this also support the "clock-frequency" property that 8250-style
> serial ports support [1]?
> 
> For the flow-control properties, should we name that more generic? The
> same property certainly makes sense for other serial-ports if it does
> here. OTOH, I'm not sure it's actually reliable, because it also depends
> on whether the other side of the connection and the cable support hw flow
> control.

I'd like to see a few use cases before defining a common property.
That said, has-rts-cts does sound like a useful generic property.
Or maybe named "uart-has-rts-cts" to make it clear that it is a uart
specific binding?

g.

> 
> 
> 	Arnd
> 
> [1] http://playground.sun.com/1275/bindings/devices/html/serial-1_0d.html#HDR9
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
