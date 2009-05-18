From: "Medve Emilian-EMMEDVE1" <Emilian.Medve@freescale.com>
Subject: RE: [PATCH] Allow selecting mv643xx_eth on Pegasos again
Date: Mon, 18 May 2009 10:48:58 -0700
Message-ID: <598D5675D34BE349929AF5EDE9B03E2702C2D323@az33exm24.fsl.freescale.net>
References: <20090518173756.GA11805@iram.es>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <tbm@cyrius.com>, "LinuxPPC" <linuxppc-dev@ozlabs.org>,
	<pacman@kosh.dhis.org>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Gabriel Paubert" <paubert@iram.es>,
	"Lennert Buytenhek" <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:54980 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbZERRtQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 13:49:16 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n4IHmx0R000701
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 10:49:00 -0700 (MST)
Received: from az33exm24.fsl.freescale.net (az33exm24.am.freescale.net [10.64.32.14])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n4IHmxSW025746
	for <netdev@vger.kernel.org>; Mon, 18 May 2009 12:48:59 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <20090518173756.GA11805@iram.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: linuxppc-dev-bounces+emilian.medve=freescale.com@ozlabs.org
[mailto:linuxppc-dev-
> bounces+emilian.medve=freescale.com@ozlabs.org] On Behalf Of Gabriel
Paubert
> Sent: Monday, May 18, 2009 12:38 PM
> To: Lennert Buytenhek
> Cc: tbm@cyrius.com; LinuxPPC; pacman@kosh.dhis.org;
netdev@vger.kernel.org; David Miller
> Subject: [PATCH] Allow selecting mv643xx_eth on Pegasos again
> 
> Since PPC_MUTIPLATFORM was removed, it was impossible to select the
> driver for mv643xx_eth on the Pegasos. Fix by allowing to select
> the driver on CHRP platforms; Pegasos is a CHRP platform and the
driver
> will not work without arch/powerpc/platforms/chrp/pegasos_eth.
> 
> Signed-off-by: Gabriel Paubert <paubert@iram.es>
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 214a92d..6fc0ff4 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2351,7 +2351,7 @@ config UGETH_TX_ON_DEMAND
> 
>  config MV643XX_ETH
>  	tristate "Marvell Discovery (643XX) and Orion ethernet support"
> -	depends on MV64360 || MV64X60 || (PPC_MULTIPLATFORM && PPC32) ||
PLAT_ORION
> +	depends on MV64X60 || PPC_CHRP || PLAT_ORION
>  	select INET_LRO
>  	select PHYLIB
>  	help

This got fixed here:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commi
tdiff;h=952ee9df26c487f2d73b2dced58ec904f19ea0f8


Cheers,
Emil.
