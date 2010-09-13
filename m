From: Joe Perches <joe@perches.com>
Subject: [PATCH 08/25] drivers/net/atl1c: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:46 -0700
Message-ID: <709846346da82e1fe8ca60953f9f4193001d6cab.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1883 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755193Ab0IMTs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 15:48:26 -0400
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/atl1c/atl1c.h      |    4 ++--
 drivers/net/atl1c/atl1c_main.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index ef4115b..05558a0 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -628,8 +628,8 @@ struct atl1c_adapter {
 #define AT_READ_REG_ARRAY(a, reg, offset) ( \
 		readl(((a)->hw_addr + reg) + ((offset) << 2)))
 
-extern char atl1c_driver_name[];
-extern char atl1c_driver_version[];
+extern const char atl1c_driver_name[];
+extern const char atl1c_driver_version[];
 
 extern int atl1c_up(struct atl1c_adapter *adapter);
 extern void atl1c_down(struct atl1c_adapter *adapter);
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 553230e..aaac76b 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -22,8 +22,8 @@
 #include "atl1c.h"
 
 #define ATL1C_DRV_VERSION "1.0.1.0-NAPI"
-char atl1c_driver_name[] = "atl1c";
-char atl1c_driver_version[] = ATL1C_DRV_VERSION;
+const char atl1c_driver_name[] = "atl1c";
+const char atl1c_driver_version[] = ATL1C_DRV_VERSION;
 #define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
 #define PCI_DEVICE_ID_ATTANSIC_L1C      0x1063
 #define PCI_DEVICE_ID_ATHEROS_L2C_B	0x2060 /* AR8152 v1.1 Fast 10/100 */
-- 
1.7.3.rc1

