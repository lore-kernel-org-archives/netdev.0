From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] mISDN: remove unnecessary variable assignments
Date: Wed, 7 Jun 2017 15:15:01 -0500
Message-ID: <20170607201501.GA7245@embeddedgus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary variable assignments.

Addresses-Coverity-ID: 1226917
Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 drivers/isdn/hardware/mISDN/mISDNipac.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 6742b0d..e240010 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -364,8 +364,8 @@ isac_mos_irq(struct isac_hw *isac)
 			WriteISAC(isac, ISAC_MOCR, isac->mocr);
 			if (isac->mon_txc && (isac->mon_txp >= isac->mon_txc)) {
 				if (isac->monitor)
-					ret = isac->monitor(isac->dch.hw,
-							    MONITOR_TX_0, NULL, 0);
+					isac->monitor(isac->dch.hw,
+						      MONITOR_TX_0, NULL, 0);
 			}
 			kfree(isac->mon_tx);
 			isac->mon_tx = NULL;
@@ -375,8 +375,8 @@ isac_mos_irq(struct isac_hw *isac)
 		}
 		if (isac->mon_txc && (isac->mon_txp >= isac->mon_txc)) {
 			if (isac->monitor)
-				ret = isac->monitor(isac->dch.hw,
-						    MONITOR_TX_0, NULL, 0);
+				isac->monitor(isac->dch.hw,
+					      MONITOR_TX_0, NULL, 0);
 			kfree(isac->mon_tx);
 			isac->mon_tx = NULL;
 			isac->mon_txc = 0;
@@ -397,8 +397,8 @@ isac_mos_irq(struct isac_hw *isac)
 			WriteISAC(isac, ISAC_MOCR, isac->mocr);
 			if (isac->mon_txc && (isac->mon_txp >= isac->mon_txc)) {
 				if (isac->monitor)
-					ret = isac->monitor(isac->dch.hw,
-							    MONITOR_TX_1, NULL, 0);
+					isac->monitor(isac->dch.hw,
+						      MONITOR_TX_1, NULL, 0);
 			}
 			kfree(isac->mon_tx);
 			isac->mon_tx = NULL;
@@ -408,8 +408,8 @@ isac_mos_irq(struct isac_hw *isac)
 		}
 		if (isac->mon_txc && (isac->mon_txp >= isac->mon_txc)) {
 			if (isac->monitor)
-				ret = isac->monitor(isac->dch.hw,
-						    MONITOR_TX_1, NULL, 0);
+				isac->monitor(isac->dch.hw,
+					      MONITOR_TX_1, NULL, 0);
 			kfree(isac->mon_tx);
 			isac->mon_tx = NULL;
 			isac->mon_txc = 0;
-- 
2.5.0
