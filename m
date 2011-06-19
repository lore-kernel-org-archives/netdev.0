From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH 1/3] serial/imx: add device tree support
Date: Sun, 19 Jun 2011 15:41:49 +0800
Message-ID: <20110619074148.GC23171@S2100-06.ap.freescale.net>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-2-git-send-email-shawn.guo@linaro.org>
 <201106181821.46574.arnd@arndb.de>
 <20110618162655.GK8195@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Arnd Bergmann <arnd@arndb.de>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	Jason Liu <jason.hui@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	Jeremy Kerr <jeremy.kerr@canonical.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	<linux-arm-kernel@lists.infradead.org>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110618162655.GK8195@ponder.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 18, 2011 at 10:26:55AM -0600, Grant Likely wrote:
> On Sat, Jun 18, 2011 at 06:21:46PM +0200, Arnd Bergmann wrote:
> > On Saturday 18 June 2011 17:19:12 Shawn Guo wrote:
> > >
> > > +Required properties:
> > > +- compatible : should be "fsl,<soc>-uart", "fsl,imx-uart"
> > > +- reg : address and length of the register set for the device
> > > +- interrupts : should contain uart interrupt
> > > +- id : should be the port ID defined by soc
> > > +
> > > +Optional properties:
> > > +- fsl,has-rts-cts : indicate it has rts-cts
> > > +- fsl,irda-mode : support irda mode
> > > +
> > > +Example:
> > > +
> > > +uart@73fbc000 {
> > > +	compatible = "fsl,imx51-uart", "fsl,imx-uart";
> > > +	reg = <0x73fbc000 0x4000>;
> > > +	interrupts = <31>;
> > > +	id = <1>;
> > > +	fsl,has-rts-cts;
> > > +};
> > 
> > Should this also support the "clock-frequency" property that 8250-style
> > serial ports support [1]?
> > 
> > For the flow-control properties, should we name that more generic? The
> > same property certainly makes sense for other serial-ports if it does
> > here. OTOH, I'm not sure it's actually reliable, because it also depends
> > on whether the other side of the connection and the cable support hw flow
> > control.
> 
> I'd like to see a few use cases before defining a common property.
> That said, has-rts-cts does sound like a useful generic property.
> Or maybe named "uart-has-rts-cts" to make it clear that it is a uart
> specific binding?
> 
I would keep the name as it is if you do not mind, since it's been
under uart node.

-- 
Regards,
Shawn
