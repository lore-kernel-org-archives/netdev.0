From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH] Allow selecting mv643xx_eth on Pegasos again
Date: Mon, 18 May 2009 13:15:12 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E2702C2D3A5@az33exm24.fsl.freescale.net>
References: <20090518173756.GA11805@iram.es> <598D5675D34BE349929AF5EDE9B03E2702C2D323@az33exm24.fsl.freescale.net> <20090518184752.GA12972@iram.es>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Lennert Buytenhek" <buytenh@wantstofly.org>, <tbm@cyrius.com>,
	"LinuxPPC" <linuxppc-dev@ozlabs.org>, <pacman@kosh.dhis.org>,
	<netdev@vger.kernel.org>, "David Miller" <davem@davemloft.net>
To: "Gabriel Paubert" <paubert@iram.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:44784 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbZERUP3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 16:15:29 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n4IKFDM8004496
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 13:15:13 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n4IKFDr0022055
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 15:15:13 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20090518184752.GA12972@iram.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Gabriel,


> -----Original Message-----
> From: Gabriel Paubert [mailto:paubert@iram.es]
> Sent: Monday, May 18, 2009 1:48 PM
> To: Medve Emilian-EMMEDVE1
> Cc: Lennert Buytenhek; tbm@cyrius.com; LinuxPPC; pacman@kosh.dhis.org;
netdev@vger.kernel.org; David
> Miller
> Subject: Re: [PATCH] Allow selecting mv643xx_eth on Pegasos again
> 
> On Mon, May 18, 2009 at 10:48:58AM -0700, Medve Emilian-EMMEDVE1
wrote:
> > > -----Original Message-----
> > > From: linuxppc-dev-bounces+emilian.medve=freescale.com@ozlabs.org
> > [mailto:linuxppc-dev-
> > > bounces+emilian.medve=freescale.com@ozlabs.org] On Behalf Of
Gabriel
> > Paubert
> > > Sent: Monday, May 18, 2009 12:38 PM
> > > To: Lennert Buytenhek
> > > Cc: tbm@cyrius.com; LinuxPPC; pacman@kosh.dhis.org;
> > netdev@vger.kernel.org; David Miller
> > > Subject: [PATCH] Allow selecting mv643xx_eth on Pegasos again
> > >
> > > Since PPC_MUTIPLATFORM was removed, it was impossible to select
the
> > > driver for mv643xx_eth on the Pegasos. Fix by allowing to select
> > > the driver on CHRP platforms; Pegasos is a CHRP platform and the
> > driver
> > > will not work without arch/powerpc/platforms/chrp/pegasos_eth.
> > >
> > > Signed-off-by: Gabriel Paubert <paubert@iram.es>
> > >
> > > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > > index 214a92d..6fc0ff4 100644
> > > --- a/drivers/net/Kconfig
> > > +++ b/drivers/net/Kconfig
> > > @@ -2351,7 +2351,7 @@ config UGETH_TX_ON_DEMAND
> > >
> > >  config MV643XX_ETH
> > >  	tristate "Marvell Discovery (643XX) and Orion ethernet support"
> > > -	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) ||
> > PLAT_ORION
> > > +	depends on MV64X60 || PPC_CHRP || PLAT_ORION
> > >  	select INET_LRO
> > >  	select PHYLIB
> > >  	help
> >
> > This got fixed here:
> >
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commi
> > tdiff;h=952ee9df26c487f2d73b2dced58ec904f19ea0f8
> 
> Ok, I was not aware of it, but the fact is that MV64360 no more exists
> and the only non MV64X60 platform that may need it is the Pegasos (to
my
> knowledge) and it relies on some platform specific code enabled
> by PPC_CHRP.

You're correct. MV64360 seems to be stale. Do you want to re-spin your
patch to get rid of it?

(I wouldn't create a dependency between MV643XX_ETH and PPC_CHRP.)
 

Cheers,
Emil.
