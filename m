From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 1/3] bnx2: Rebranding bnx2 driver.
Date: Mon, 23 Jun 2014 15:10:33 -0400
Message-ID: <1403550635-19700-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1403550635-19700-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62594 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756707AbaFWTlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 15:41:23 -0400
In-Reply-To: <1403550635-19700-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o QLogic has acquired the NetXtremeII products and drivers from Broadcom.
  This patch re-brands bnx2 driver as a QLogic driver
---
 drivers/net/ethernet/broadcom/Kconfig   |    4 ++--
 drivers/net/ethernet/broadcom/bnx2.c    |    9 +++++----
 drivers/net/ethernet/broadcom/bnx2.h    |    5 +++--
 drivers/net/ethernet/broadcom/bnx2_fw.h |    3 ++-
 4 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 3e48809..0bde471 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -72,12 +72,12 @@ config BCMGENET
 	  Broadcom BCM7xxx Set Top Box family chipset.
 
 config BNX2
-	tristate "Broadcom NetXtremeII support"
+	tristate "QLogic NetXtremeII support"
 	depends on PCI
 	select CRC32
 	select FW_LOADER
 	---help---
-	  This driver supports Broadcom NetXtremeII gigabit Ethernet cards.
+	  This driver supports QLogic NetXtremeII gigabit Ethernet cards.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2.  This is recommended.
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 67d2b00..e64c963 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -1,6 +1,7 @@
-/* bnx2.c: Broadcom NX2 network driver.
+/* bnx2.c: QLogic NX2 network driver.
  *
- * Copyright (c) 2004-2013 Broadcom Corporation
+ * Copyright (c) 2004-2014 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -71,10 +72,10 @@
 #define TX_TIMEOUT  (5*HZ)
 
 static char version[] =
-	"Broadcom NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+	"QLogic NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
-MODULE_DESCRIPTION("Broadcom NetXtreme II BCM5706/5708/5709/5716 Driver");
+MODULE_DESCRIPTION("QLogic NetXtreme II BCM5706/5708/5709/5716 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_FIRMWARE(FW_MIPS_FILE_06);
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index e341bc3..28df35d 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -1,6 +1,7 @@
-/* bnx2.h: Broadcom NX2 network driver.
+/* bnx2.h: QLogic NX2 network driver.
  *
- * Copyright (c) 2004-2013 Broadcom Corporation
+ * Copyright (c) 2004-2014 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2_fw.h b/drivers/net/ethernet/broadcom/bnx2_fw.h
index 940eb91..7db79c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2_fw.h
+++ b/drivers/net/ethernet/broadcom/bnx2_fw.h
@@ -1,6 +1,7 @@
-/* bnx2_fw.h: Broadcom NX2 network driver.
+/* bnx2_fw.h: QLogic NX2 network driver.
  *
  * Copyright (c) 2004, 2005, 2006, 2007 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.7.9.5
