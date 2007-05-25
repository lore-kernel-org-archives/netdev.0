From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH] Add select PHYLIB to the UCC_GETH Kconfig option
Date: Fri, 25 May 2007 11:47:15 +0800
Message-ID: <989B956029373F45A0B8AF0297081890B768B8@zch01exm26.fsl.freescale.net>
References: <4656080F.4080006@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Phillips Kim-R1AAHA" <Kim.Phillips@freescale.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Jan Altenberg" <jan.altenberg@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60917 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbXEYDpd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 23:45:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4656080F.4080006@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: netdev-owner@vger.kernel.org
[mailto:netdev-owner@vger.kernel.org] On
> Behalf Of Jeff Garzik
> Sent: Friday, May 25, 2007 5:48 AM
> To: Jan Altenberg
> Cc: Phillips Kim-R1AAHA; linux-kernel@vger.kernel.org;
netdev@vger.kernel.org
> Subject: Re: [PATCH] Add select PHYLIB to the UCC_GETH Kconfig option
> 
> Jan Altenberg wrote:
> > ucc_geth has been migrated to use the common phylib code. So lets
add a
> > 'select PHYLIB' to the UCC_GETH Kconfig entry.
> >
> > Signed-off-by: Jan Altenberg <jan.altenberg@linutronix.de>
> >
> > ---
> >  drivers/net/Kconfig |    1 +
> >  1 file changed, 1 insertion(+)
> >
> > Index: linux-2.6/drivers/net/Kconfig
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/Kconfig
> > +++ linux-2.6/drivers/net/Kconfig
> > @@ -2280,6 +2280,7 @@ config GFAR_NAPI
> >  config UCC_GETH
> >  	tristate "Freescale QE Gigabit Ethernet"
> >  	depends on QUICC_ENGINE
> > +	select PHYLIB
> >  	select UCC_FAST
> 
> Please fix the Kconfig warnings first.
> 

I will follow up this.

> Also, I ask again:  WHO IS THE MAINTAINER OF THIS DRIVER?
> 
> I am tired of five independent people patching the same driver.

Sorry for the trouble, I will post a patch to the MAINTAINER file and
help to maintain ucc_geth related patches.

- Leo
