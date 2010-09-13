From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/25] drivers/net/atl1e: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:47 -0700
Message-ID: <695286413101e74814ff1a905e4b980d80fdd1a3.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1885 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755219Ab0IMTs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 15:48:27 -0400
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/atl1e/atl1e.h      |    4 ++--
 drivers/net/atl1e/atl1e_main.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1e/atl1e.h b/drivers/net/atl1e/atl1e.h
index 490d3b3..6c4cab3 100644
--- a/drivers/net/atl1e/atl1e.h
+++ b/drivers/net/atl1e/atl1e.h
@@ -498,8 +498,8 @@ struct atl1e_adapter {
 #define AT_READ_REG_ARRAY(a, reg, offset) ( \
 		readl(((a)->hw_addr + reg) + ((offset) << 2)))
 
-extern char atl1e_driver_name[];
-extern char atl1e_driver_version[];
+extern const char atl1e_driver_name[];
+extern const char atl1e_driver_version[];
 
 extern void atl1e_check_options(struct atl1e_adapter *adapter);
 extern int atl1e_up(struct atl1e_adapter *adapter);
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 56ace3f..860dfd3 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -23,8 +23,8 @@
 
 #define DRV_VERSION "1.0.0.7-NAPI"
 
-char atl1e_driver_name[] = "ATL1E";
-char atl1e_driver_version[] = DRV_VERSION;
+const char atl1e_driver_name[] = "ATL1E";
+const char atl1e_driver_version[] = DRV_VERSION;
 #define PCI_DEVICE_ID_ATTANSIC_L1E      0x1026
 /*
  * atl1e_pci_tbl - PCI Device ID Table
-- 
1.7.3.rc1

