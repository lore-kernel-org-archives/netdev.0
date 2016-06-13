From: Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 2/2] ARM: dts: imx6: tag boards that have the HW
 workaround for ERR006687
Date: Mon, 13 Jun 2016 13:03:18 +0200
Message-ID: <1465815798.2313.13.camel@pengutronix.de>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
	 <1464794983-31484-3-git-send-email-l.stach@pengutronix.de>
	 <20160601161729.GB19428@n2100.arm.linux.org.uk>
	 <1464855906.9501.1.camel@pengutronix.de>
	 <20160607124650.1e69c658@jclayton-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patchwork-lst-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Shawn Guo <shawnguo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Joshua Clayton <stillcompiling-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160607124650.1e69c658@jclayton-pc>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 07.06.2016, 12:46 -0700 schrieb Joshua Clayton:
> On Thu, 02 Jun 2016 10:25:06 +0200
> Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org> wrote:
> 
> > Am Mittwoch, den 01.06.2016, 17:17 +0100 schrieb Russell King - ARM
> > Linux:
> > > On Wed, Jun 01, 2016 at 05:29:43PM +0200, Lucas Stach wrote:  
> > > > @@ -97,6 +97,7 @@
> > > >  	phy-reset-gpios = <&gpio3 31 0>;
> > > >  	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
> > > >  			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
> > > > +	fsl,err006687-war-present;  
> > > 
> 
> Why can't we just have the quirk detect the interrupts-extended
> property, which is not present on boards without the workaround.
> Wouldn't that be better? No dts change needed.
> 
I pondered that idea too, but have gone with the solution presented in
this patch series as it's more explicit and - with far more weight to it
- does not require the driver to touch DT properties that are outside of
its domain of responsibility. The "interrupts-extended" properties are
not meant to be parsed by the driver, but rather the IRQ subsystem.

Regards,
Lucas

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
