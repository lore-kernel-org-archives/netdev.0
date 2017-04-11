From: Fugang Duan <fugang.duan@nxp.com>
Subject: [PATCH net-next 6/6] net: fec: add ERR007885 for i.MX6ul enet IP
Date: Tue, 11 Apr 2017 19:13:08 +0800
Message-ID: <1491909188-8971-7-git-send-email-fugang.duan@nxp.com>
References: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
        <stephen@networkplumber.org>, <fugang.duan@nxp.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0053.outbound.protection.outlook.com ([104.47.38.53]:39161
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754624AbdDKLP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 07:15:29 -0400
In-Reply-To: <1491909188-8971-1-git-send-email-fugang.duan@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The errata ERR007885 HW fix don't add to i.MX6ul ENET IP version,
so add sw workaroud for the chip.

Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f3a7835..a92bf94 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -117,8 +117,9 @@
 		.name = "imx6ul-fec",
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
-				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_BUG_CAPTURE |
-				FEC_QUIRK_HAS_RACC | FEC_QUIRK_HAS_COALESCE,
+				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_ERR007885 |
+				FEC_QUIRK_BUG_CAPTURE | FEC_QUIRK_HAS_RACC |
+				FEC_QUIRK_HAS_COALESCE,
 	}, {
 		/* sentinel */
 	}
-- 
1.9.1
