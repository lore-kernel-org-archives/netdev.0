From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH 0/3] net: fec: updates to align IP header
Date: Sat, 24 Sep 2016 15:09:14 +0000
Message-ID: <AM4PR0401MB2260BDF848F89A445B1D013BFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: Eric Nelson <eric@nelint.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0087.outbound.protection.outlook.com ([104.47.2.87]:12615
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753315AbcIXPJR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Sep 2016 11:09:17 -0400
In-Reply-To: <1474728139-9335-1-git-send-email-eric@nelint.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Nelson <eric@nelint.com> Sent: Saturday, September 24, 2016 10:4=
2 PM
> To: netdev@vger.kernel.org
> Cc: linux@arm.linux.org.uk; andrew@lunn.ch; Andy Duan
> <fugang.duan@nxp.com>; otavio@ossystems.com.br;
> edumazet@google.com; troy.kisky@boundarydevices.com;
> davem@davemloft.net; u.kleine-koenig@pengutronix.de; Eric Nelson
> <eric@nelint.com>
> Subject: [PATCH 0/3] net: fec: updates to align IP header
>=20
> This patch series is the outcome of investigation into very high numbers =
of
> alignment faults on kernel 4.1.33 from the linux-fslc
> tree:
>     https://github.com/freescale/linux-fslc/tree/4.1-1.0.x-imx
>=20
> The first two patches remove support for the receive accelerator (RACC)
> from the i.MX25 and i.MX27 SoCs which don't support the function.
>=20
> The third patch enables hardware alignment of the ethernet packet payload
> (and especially the IP header) to prevent alignment faults in the IP stac=
k.
>=20
> Testing on i.MX6UL on the 4.1.33 kernel showed that this patch removed on
> the order of 70k alignment faults during a 100MiB transfer using wget.
>=20
> Testing on an i.MX6Q (SABRE Lite) board on net-next (4.8.0-rc7) showed a
> much more modest improvement from 10's of faults, and it's not clear why
> that's the case.
>=20
> Eric Nelson (3):
>   net: fec: remove QUIRK_HAS_RACC from i.mx25
>   net: fec: remove QUIRK_HAS_RACC from i.mx27
>   net: fec: align IP header in hardware
>=20
>  drivers/net/ethernet/freescale/fec_main.c | 15 ++++++++++++---
>  1 file changed, 12 insertions(+), 3 deletions(-)
>=20
> --
> 2.7.4
I will investigate the diff between 4.1 and 4.8. Thanks.

Acked-by: Fugang Duan <fugang.duan@nxp.com>
