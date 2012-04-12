From: Gabor Juhos <juhosg@openwrt.org>
Subject: Re: [PATCH 4/4] net: Remove redundant spi driver bus initialization
Date: Thu, 12 Apr 2012 08:23:27 +0200
Message-ID: <4F8674DF.3070101@openwrt.org>
References: <1334091089-10138-1-git-send-email-lars@metafoo.de> <1334091089-10138-4-git-send-email-lars@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Frederic Lambert <frdrc66@gmail.com>, netdev@vger.kernel.org
To: Lars-Peter Clausen <lars@metafoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:47501 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757129Ab2DLGb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 02:31:26 -0400
In-Reply-To: <1334091089-10138-4-git-send-email-lars@metafoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012.04.10. 22:51 keltez=E9ssel, Lars-Peter Clausen =EDrta:
> In ancient times it was necessary to manually initialize the bus fiel=
d of an
> spi_driver to spi_bus_type. These days this is done in spi_driver_reg=
ister() so
> we can drop the manual assignment.
>=20
> The patch was generated using the following coccinelle semantic patch=
:
> // <smpl>
> @@
> identifier _driver;
> @@
> struct spi_driver _driver =3D {
> 	.driver =3D {
> -		.bus =3D &spi_bus_type,
> 	},
> };
> // </smpl>
>=20
> Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Gabor Juhos <juhosg@openwrt.org>
> Cc: Frederic Lambert <frdrc66@gmail.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/phy/spi_ks8995.c |    1 -
>  1 file changed, 1 deletion(-)

Acked-by: Gabor Juhos <juhosg@openwrt.org>
