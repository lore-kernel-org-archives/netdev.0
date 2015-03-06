From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH v2 0/3] net: macb: rework at91 specific handling
Date: Fri, 6 Mar 2015 17:44:44 +0100
Message-ID: <54F9D97C.3050100@atmel.com>
References: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	"Alexandre Belloni" <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	"Kumar Gala" <galak@codeaurora.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Boris Brezillon <boris.brezillon@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425637442-8724-1-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 06/03/2015 11:23, Boris Brezillon a =E9crit :
> Hello,
>=20
> This removes the #if defined(ARCH_AT91) sections to prevent any probl=
em
> when enabling ARM multi-platform support.
> The at91 specific logic is now activated when the "at91sam9260-macb"
> compatible string is found.=20
>=20
> Best Regards,
>=20
> Boris

I'm okay with the whole series:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

>=20
> Changes since v1:
> - avoid changing existing behavior as Alexandre suggested
>=20
> Boris Brezillon (3):
>   net/macb: Update DT bindings documentation
>   ARM: at91/dt: fix macb compatible strings
>   net: macb: remove #if defined(CONFIG_ARCH_AT91) sections
>=20
>  Documentation/devicetree/bindings/net/macb.txt |  5 +++-
>  arch/arm/boot/dts/at91sam9260.dtsi             |  2 +-
>  arch/arm/boot/dts/at91sam9263.dtsi             |  2 +-
>  arch/arm/boot/dts/at91sam9g45.dtsi             |  2 +-
>  arch/arm/boot/dts/at91sam9x5_macb0.dtsi        |  2 +-
>  arch/arm/boot/dts/at91sam9x5_macb1.dtsi        |  2 +-
>  arch/arm/boot/dts/sama5d3_emac.dtsi            |  2 +-
>  drivers/net/ethernet/cadence/macb.c            | 32 ++++++++++++++--=
----------
>  drivers/net/ethernet/cadence/macb.h            |  2 ++
>  9 files changed, 29 insertions(+), 22 deletions(-)
>=20


--=20
Nicolas Ferre
