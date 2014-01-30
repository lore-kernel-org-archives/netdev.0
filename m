From: Florian Vaussard <florian.vaussard@epfl.ch>
Subject: [PATCH 1/5] can: sja1000: remove unused defines
Date: Thu, 30 Jan 2014 15:29:24 +0100
Message-ID: <1391092168-21246-2-git-send-email-florian.vaussard@epfl.ch>
References: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, florian.vaussard@epfl.ch
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391092168-21246-1-git-send-email-florian.vaussard@epfl.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unused defines for the OF platform.

Signed-off-by: Florian Vaussard <florian.vaussard@epfl.ch>
---
 drivers/net/can/sja1000/sja1000_of_platform.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 047accd..2f29eb9 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -55,9 +55,6 @@ MODULE_LICENSE("GPL v2");
 
 #define SJA1000_OFP_CAN_CLOCK  (16000000 / 2)
 
-#define SJA1000_OFP_OCR        OCR_TX0_PULLDOWN
-#define SJA1000_OFP_CDR        (CDR_CBP | CDR_CLK_OFF)
-
 static u8 sja1000_ofp_read_reg(const struct sja1000_priv *priv, int reg)
 {
 	return ioread8(priv->reg_base + reg);
-- 
1.8.1.2
