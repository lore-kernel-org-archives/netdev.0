From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: cadence: Enable MACB driver for ARM64
Date: Tue, 24 Feb 2015 09:56:32 +0100
Message-ID: <54EC3CC0.8070906@atmel.com>
References: <5a2ef83a03f6df78c8de643a19fb3f6105d892f4.1424763946.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Michal Simek <michal.simek@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <monstr@monstr.eu>,
	<netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5a2ef83a03f6df78c8de643a19fb3f6105d892f4.1424763946.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 24/02/2015 08:45, Michal Simek a =C3=A9crit :
> This driver is used on new Xilinx ZynqMP SoC.
>=20
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
> Acked-by: S=C3=B6ren Brinkmann <soren.brinkmann@xilinx.com>

I see no objection on my side:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>=20
>  drivers/net/ethernet/cadence/Kconfig | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ether=
net/cadence/Kconfig
> index 321d2ad235d9..4562f90c0348 100644
> --- a/drivers/net/ethernet/cadence/Kconfig
> +++ b/drivers/net/ethernet/cadence/Kconfig
> @@ -4,7 +4,7 @@
> =20
>  config NET_CADENCE
>  	bool "Cadence devices"
> -	depends on HAS_IOMEM && (ARM || AVR32 || MICROBLAZE || COMPILE_TEST=
)
> +	depends on HAS_IOMEM && (ARM || ARM64 || AVR32 || MICROBLAZE || COM=
PILE_TEST)
>  	default y
>  	---help---
>  	  If you have a network (Ethernet) card belonging to this class, sa=
y Y.
> @@ -30,7 +30,7 @@ config ARM_AT91_ETHER
> =20
>  config MACB
>  	tristate "Cadence MACB/GEM support"
> -	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCE=
LL || ARCH_ZYNQ || MICROBLAZE || COMPILE_TEST)
> +	depends on HAS_DMA && (PLATFORM_AT32AP || ARCH_AT91 || ARCH_PICOXCE=
LL || ARCH_ZYNQ || ARM64 || MICROBLAZE || COMPILE_TEST)
>  	select PHYLIB
>  	---help---
>  	  The Cadence MACB ethernet interface is found on many Atmel AT32 a=
nd
>=20


--=20
Nicolas Ferre
