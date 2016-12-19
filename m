From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net v4 1/4] fsl/fman: fix 1G support for QSGMII interfaces
Date: Mon, 19 Dec 2016 22:42:43 +0200
Message-ID: <1482180166-10677-2-git-send-email-madalin.bucur@nxp.com>
References: <1482180166-10677-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <scott.wood@nxp.com>, <mpe@ellerman.id.au>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482180166-10677-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QSGMII ports were not advertising 1G speed.

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
Reviewed-by: Camelia Groza <camelia.groza@nxp.com>
---
 drivers/net/ethernet/freescale/fman/mac.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fman/mac.c b/drivers/net/ethernet/freescale/fman/mac.c
index 69ca42c..0b31f85 100644
--- a/drivers/net/ethernet/freescale/fman/mac.c
+++ b/drivers/net/ethernet/freescale/fman/mac.c
@@ -594,6 +594,7 @@ static const u16 phy2speed[] = {
 	[PHY_INTERFACE_MODE_RGMII_RXID]	= SPEED_1000,
 	[PHY_INTERFACE_MODE_RGMII_TXID]	= SPEED_1000,
 	[PHY_INTERFACE_MODE_RTBI]		= SPEED_1000,
+	[PHY_INTERFACE_MODE_QSGMII]		= SPEED_1000,
 	[PHY_INTERFACE_MODE_XGMII]		= SPEED_10000
 };
 
-- 
2.1.0
