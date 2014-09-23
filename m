From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 2/4] net: fec: remove the ERR006358 workaround for imx6sx enet
Date: Tue, 23 Sep 2014 15:40:56 +0800
Message-ID: <1411458058-18934-3-git-send-email-b38611@freescale.com>
References: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b20596@freescale.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0115.outbound.protection.outlook.com ([207.46.100.115]:59072
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754439AbaIWIYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 04:24:06 -0400
In-Reply-To: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the ERR006358 workaround for imx6sx enet since the hw issue
was fixed on the SOC.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index a0f21ce..e87a8e9 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -144,8 +144,8 @@ static struct platform_device_id fec_devtype[] = {
 		.name = "imx6sx-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
-				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR006358 |
-				FEC_QUIRK_HAS_AVB | FEC_QUIRK_ERR007885,
+				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_HAS_AVB |
+				FEC_QUIRK_ERR007885,
 	}, {
 		/* sentinel */
 	}
-- 
1.7.8
