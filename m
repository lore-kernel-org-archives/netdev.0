From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 0/3] fec: Do not use NULL pointer to indicate
 error
Date: Tue, 2 Sep 2014 01:37:08 +0000
Message-ID: <a4c62d08ec774f14b7d7662b1c593b9f@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0181.outbound.protection.outlook.com ([207.46.163.181]:8090
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751227AbaIBBhL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:37:11 -0400
In-Reply-To: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com> Sent: Tuesday, September 02, 2014 9:13 AM
>To: davem@davemloft.net
>Cc: linux@arm.linux.org.uk; Duan Fugang-B38611; netdev@vger.kernel.org;
>Estevam Fabio-R49496
>Subject: [PATCH net-next 0/3] fec: Do not use NULL pointer to indicate
>error
>
>From: Fabio Estevam <fabio.estevam@freescale.com>
>
>Using IS_ERR() to indicate error can simplify the code a bit, so let's use
>it when appropriate.
>
>Fabio Estevam (3):
>  fec: Do not set fep->clk_ptp to NULL on error
>  fec: Do not set fep->clk_enet_out to NULL on error
>  fec: Do not set fep->reg_phy to NULL on error
>
> drivers/net/ethernet/freescale/fec_main.c | 28 +++++++++++---------------
>--
> 1 file changed, 11 insertions(+), 17 deletions(-)
>
>--
>1.9.1

The patch serial are fine.

Acked-by: Fugang Duan <B38611@freescale.com>

Thanks,
Andy
