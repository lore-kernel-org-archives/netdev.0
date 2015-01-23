From: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
Subject: [PATCH bluetooth-next] ieee802154: cc2520: Replace shift operations by BIT macro
Date: Fri, 23 Jan 2015 19:28:29 +0530
Message-ID: <1422021509-18877-1-git-send-email-md.jamalmohiuddin@gmail.com>
Cc: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
To: varkabhadram@gmail.com, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces the shifting operations by BIT macro

Signed-off-by: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
---
 drivers/net/ieee802154/cc2520.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/cc2520.c
index 665a3db..181b349 100644
--- a/drivers/net/ieee802154/cc2520.c
+++ b/drivers/net/ieee802154/cc2520.c
@@ -44,9 +44,9 @@
 #define	CC2520_FREG_MASK	0x3F
 
 /* status byte values */
-#define	CC2520_STATUS_XOSC32M_STABLE	(1 << 7)
-#define	CC2520_STATUS_RSSI_VALID	(1 << 6)
-#define	CC2520_STATUS_TX_UNDERFLOW	(1 << 3)
+#define	CC2520_STATUS_XOSC32M_STABLE	BIT(7)
+#define	CC2520_STATUS_RSSI_VALID	BIT(6)
+#define	CC2520_STATUS_TX_UNDERFLOW	BIT(3)
 
 /* IEEE-802.15.4 defined constants (2.4 GHz logical channels) */
 #define	CC2520_MINCHANNEL		11
-- 
1.7.9.5
