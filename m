From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sun, 19 Jun 2011 15:40:11 +0800
Message-ID: <20110619074010.GB23171@S2100-06.ap.freescale.net>
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
I would ignore it for a while until we have common clock api and
corresponding binding settled.  For now, I would have nothing clock
related parsed from device tree.

-- 
Regards,
Shawn
