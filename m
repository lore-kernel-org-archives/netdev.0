From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH v4 2/3] net: fec: remove unused interrupt
 FEC_ENET_TS_TIMER
Date: Wed, 20 Sep 2017 02:14:49 +0000
Message-ID: <AM4PR0401MB22607775B0B26322C759D719FF610@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1505867589-11784-1-git-send-email-troy.kisky@boundarydevices.com>
 <1505867589-11784-2-git-send-email-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
        "lznuaa@gmail.com" <lznuaa@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0078.outbound.protection.outlook.com ([104.47.0.78]:45440
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750872AbdITCOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 22:14:52 -0400
In-Reply-To: <1505867589-11784-2-git-send-email-troy.kisky@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, Septembe=
r 20, 2017 8:33 AM
>FEC_ENET_TS_TIMER is not checked in the interrupt routine so there is no
>need to enable it.
>
>Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>Acked-by: Fugang Duan <fugang.duan@nxp.com>
>
>---
>v4: Added Acked-by
>
>Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>---

Troy, thank you for submitting the version.
The patch series had been already acked by me.

Thanks again.

> drivers/net/ethernet/freescale/fec.h | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/drivers/net/ethernet/freescale/fec.h
>b/drivers/net/ethernet/freescale/fec.h
>index 38c7b21..ede1876 100644
>--- a/drivers/net/ethernet/freescale/fec.h
>+++ b/drivers/net/ethernet/freescale/fec.h
>@@ -374,8 +374,8 @@ struct bufdesc_ex {
> #define FEC_ENET_TS_AVAIL       ((uint)0x00010000)
> #define FEC_ENET_TS_TIMER       ((uint)0x00008000)
>
>-#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF |
>FEC_ENET_MII | FEC_ENET_TS_TIMER)
>-#define FEC_NAPI_IMASK	(FEC_ENET_MII | FEC_ENET_TS_TIMER)
>+#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF |
>FEC_ENET_MII)
>+#define FEC_NAPI_IMASK	FEC_ENET_MII
> #define FEC_RX_DISABLED_IMASK (FEC_DEFAULT_IMASK &
>(~FEC_ENET_RXF))
>
> /* ENET interrupt coalescing macro define */
>--
>2.7.4
