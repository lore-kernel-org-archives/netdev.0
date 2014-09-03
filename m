From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 4/4] amd-xgbe-phy: Checkpatch driver fixes
Date: Wed, 3 Sep 2014 12:14:39 -0500
Message-ID: <20140903171439.9710.47961.stgit@tlendack-t1.amdoffice.net>
References: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0144.outbound.protection.outlook.com ([65.55.169.144]:10539
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753359AbaICRs6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 13:48:58 -0400
In-Reply-To: <20140903171410.9710.37086.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch contains fixes identified by checkpatch when run with the
strict option.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index da351d3..4e1f7f7 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -75,7 +75,6 @@
 #include <linux/of_device.h>
 #include <linux/uaccess.h>
 
-
 MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION("1.0.0-a");
@@ -172,7 +171,6 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define SPEED_1000_TXAMP		0xf
 #define SPEED_1000_WORD			0x1
 
-
 /* SerDes RxTx register offsets */
 #define RXTX_REG20			0x0050
 #define RXTX_REG114			0x01c8
@@ -266,7 +264,6 @@ do {									\
 	XSIR1_IOWRITE((_priv), _reg, reg_val);				\
 } while (0)
 
-
 /* Macros for reading or writing SerDes RxTx registers
  *  The ioread macros will get bit fields or full values using the
  *  register definitions formed using the input names
@@ -294,7 +291,6 @@ do {									\
 	XRXTX_IOWRITE((_priv), _reg, reg_val);				\
 } while (0)
 
-
 enum amd_xgbe_phy_an {
 	AMD_XGBE_AN_READY = 0,
 	AMD_XGBE_AN_START,
