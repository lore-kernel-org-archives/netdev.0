From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 02/12] amd-xgbe-phy: Checkpatch fixes
Date: Fri, 16 Jan 2015 12:46:29 -0600
Message-ID: <20150116184629.18809.6847.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44029 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756799AbbAPSya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:30 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches resolves some checks reported by the checkpatch
tool.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 903dc3d..b65a0a8 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -74,6 +74,7 @@
 #include <linux/of_platform.h>
 #include <linux/of_device.h>
 #include <linux/uaccess.h>
+#include <linux/bitops.h>
 
 MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
 MODULE_LICENSE("Dual BSD/GPL");
@@ -90,9 +91,9 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XGBE_AN_PG_RCV			0x04
 
 #define XNP_MCF_NULL_MESSAGE		0x001
-#define XNP_ACK_PROCESSED		(1 << 12)
-#define XNP_MP_FORMATTED		(1 << 13)
-#define XNP_NP_EXCHANGE			(1 << 15)
+#define XNP_ACK_PROCESSED		BIT(12)
+#define XNP_MP_FORMATTED		BIT(13)
+#define XNP_NP_EXCHANGE			BIT(15)
 
 #define XGBE_PHY_RATECHANGE_COUNT	500
 
