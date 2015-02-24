From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH] net: cadence: Enable MACB driver for ARM64
Date: Tue, 24 Feb 2015 20:12:34 +0800
Message-ID: <59CA6960-8233-4D87-A337-0C7E10FD562A@jcrosoft.com>
References: <5a2ef83a03f6df78c8de643a19fb3f6105d892f4.1424763946.git.michal.simek@xilinx.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	linux-kernel@vger.kernel.org, monstr@monstr.eu,
	Nicolas FERRE <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 3.mo2.mail-out.ovh.net ([46.105.58.226]:33698 "EHLO
	3.mo2.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbbBXNcH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 08:32:07 -0500
Received: from mail613.ha.ovh.net (b9.ovh.net [213.186.33.59])
	by mo2.mail-out.ovh.net (Postfix) with SMTP id 056E1FFAF70
	for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 13:12:42 +0100 (CET)
In-Reply-To: <5a2ef83a03f6df78c8de643a19fb3f6105d892f4.1424763946.git.michal.simek@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 24, 2015, at 3:45 PM, Michal Simek <michal.simek@xilinx.com> w=
rote:
>=20
> This driver is used on new Xilinx ZynqMP SoC.
>=20
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>
> ---
>=20
> drivers/net/ethernet/cadence/Kconfig | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ether=
net/cadence/Kconfig
> index 321d2ad235d9..4562f90c0348 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -4,7 +4,7 @@
>=20
> config NET_CADENCE
> 	bool "Cadence devices"
> -	depends on HAS_IOMEM && (ARM || AVR32 || MICROBLAZE || COMPILE_TEST=
)
> +	depends on HAS_IOMEM && (ARM || ARM64 || AVR32 || MICROBLAZE || COM=
PILE_TEST)

drop the arch test just put HAS_IOMEM

Best Regards,
J.
> 	default y
> 	---help---
> 	  If you have a network (Ethernet) card belonging to this class, say=
 Y.
> @@ -30,7 +30,7 @@ config ARM_AT91_ETHER
>=20
> config MACB
> 	tristate "Cadence MACB/GEM support"
> -	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCE=
LL || ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST)
> +	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCE=
LL || ARCH_ZYNQ || ARM64 || MICROBLAZE || COMPILE_TEST)
> 	select PHYLIB
> 	---help---
> 	  The Cadence MACB ethernet interface is found on many Atmel AT32 an=
d
> --=20
> 1.8.2.3
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
