From: Joshua Clayton <stillcompiling@gmail.com>
Subject: Re: [PATCH 2/2] ARM: dts: imx6: tag boards that have the HW
 workaround for ERR006687
Date: Tue, 7 Jun 2016 12:46:50 -0700
Message-ID: <20160607124650.1e69c658@jclayton-pc>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
	<1464794983-31484-3-git-send-email-l.stach@pengutronix.de>
	<20160601161729.GB19428@n2100.arm.linux.org.uk>
	<1464855906.9501.1.camel@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>,
	devicetree@vger.kernel.org, Fugang Duan <fugang.duan@nxp.com>,
	netdev@vger.kernel.org, patchwork-lst@pengutronix.de,
	kernel@pengutronix.de, Shawn Guo <shawnguo@kernel.org>,
	linux-arm-kernel@lists.infradead.org
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33670 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbcFGTrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 15:47:00 -0400
In-Reply-To: <1464855906.9501.1.camel@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 02 Jun 2016 10:25:06 +0200
Lucas Stach <l.stach@pengutronix.de> wrote:

> Am Mittwoch, den 01.06.2016, 17:17 +0100 schrieb Russell King - ARM
> Linux:
> > On Wed, Jun 01, 2016 at 05:29:43PM +0200, Lucas Stach wrote:  
> > > @@ -97,6 +97,7 @@
> > >  	phy-reset-gpios = <&gpio3 31 0>;
> > >  	interrupts-extended = <&gpio1 6 IRQ_TYPE_LEVEL_HIGH>,
> > >  			      <&intc 0 119 IRQ_TYPE_LEVEL_HIGH>;
> > > +	fsl,err006687-war-present;  
> > 

Why can't we just have the quirk detect the interrupts-extended
property, which is not present on boards without the workaround.
Wouldn't that be better? No dts change needed.

> > war?  Any reason not to spell it out, or use the more natural
> > abbreviation "wa"?
> >   
> Apparently I've read too many documents where WAR is the abbreviation
> for workaround, so it felt completely natural to me. I agree that it
> would make sense to just spell it out to avoid any confusion.
> 
> Regards,
> Lucas
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
