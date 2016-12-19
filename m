From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH 3/3] net: fec: Fix typo in error msg and comment
Date: Mon, 19 Dec 2016 02:14:33 +0000
Message-ID: <AM4PR0401MB2260FD3080A50A345D671FF4FF910@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1481894616-4517-1-git-send-email-pmeerw@pmeerw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "trivial@kernel.org" <trivial@kernel.org>
To: Peter Meerwald-Stadler <pmeerw@pmeerw.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0089.outbound.protection.outlook.com ([104.47.2.89]:1104
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752111AbcLSFrI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 00:47:08 -0500
In-Reply-To: <1481894616-4517-1-git-send-email-pmeerw@pmeerw.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Meerwald-Stadler <pmeerw@pmeerw.net> Sent: Friday, December 16,=
 2016 9:24 PM
>To: netdev@vger.kernel.org
>Cc: Peter Meerwald-Stadler <pmeerw@pmeerw.net>; Andy Duan
><fugang.duan@nxp.com>; trivial@kernel.org
>Subject: [PATCH 3/3] net: fec: Fix typo in error msg and comment
>
>Signed-off-by: Peter Meerwald-Stadler <pmeerw@pmeerw.net>
>Cc: Fugang Duan <fugang.duan@nxp.com>
>Cc: trivial@kernel.org
>---
> drivers/net/ethernet/freescale/fec_main.c |    4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>

Acked-by: Fugang Duan <fugang.duan@nxp.com>

>diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>index 38160c2..250b790 100644
>--- a/drivers/net/ethernet/freescale/fec_main.c
>+++ b/drivers/net/ethernet/freescale/fec_main.c
>@@ -2001,7 +2001,7 @@ static int fec_enet_mii_init(struct platform_device
>*pdev)
> 		mii_speed--;
> 	if (mii_speed > 63) {
> 		dev_err(&pdev->dev,
>-			"fec clock (%lu) to fast to get right mii speed\n",
>+			"fec clock (%lu) too fast to get right mii speed\n",
> 			clk_get_rate(fep->clk_ipg));
> 		err =3D -EINVAL;
> 		goto err_out;
>@@ -2950,7 +2950,7 @@ static void set_multicast_list(struct net_device
>*ndev)
> 		}
>
> 		/* only upper 6 bits (FEC_HASH_BITS) are used
>-		 * which point to specific bit in he hash registers
>+		 * which point to specific bit in the hash registers
> 		 */
> 		hash =3D (crc >> (32 - FEC_HASH_BITS)) & 0x3f;
>
>--
>1.7.10.4
