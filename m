From: Lucas Stach <l.stach-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH 2/2] ARM: dts: imx6: tag boards that have the HW
 workaround for ERR006687
Date: Thu, 02 Jun 2016 10:25:06 +0200
Message-ID: <1464855906.9501.1.camel@pengutronix.de>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
	 <1464794983-31484-3-git-send-email-l.stach@pengutronix.de>
	 <20160601161729.GB19428@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shawn Guo <shawnguo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Fugang Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, patchwork-lst-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160601161729.GB19428-l+eeeJia6m9vn6HldHNs0ANdhmdF6hFW@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, den 01.06.2016, 17:17 +0100 schrieb Russell King - ARM
Linux:
> On Wed, Jun 01, 2016 at 05:29:43PM +0200, Lucas Stach wrote:
> > @@ -97,6 +97,7 @@
> >  	phy-reset-gpios = <&gpio3 31 0>;
> >  	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
> >  			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
> > +	fsl,err006687-war-present;
> 
> war?  Any reason not to spell it out, or use the more natural
> abbreviation "wa"?
> 
Apparently I've read too many documents where WAR is the abbreviation
for workaround, so it felt completely natural to me. I agree that it
would make sense to just spell it out to avoid any confusion.

Regards,
Lucas

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
