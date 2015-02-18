From: Rasesh Mody <rasesh.mody@qlogic.com>
Subject: [net-next 1/3] bnx2-cnic: Driver Rebranding Changes
Date: Tue, 17 Feb 2015 19:26:18 -0500
Message-ID: <1424219180-29028-2-git-send-email-rasesh.mody@qlogic.com>
References: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Dept-HSGLinuxNICDev@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49151 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbbBRBGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 20:06:00 -0500
In-Reply-To: <1424219180-29028-1-git-send-email-rasesh.mody@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides additional changes as a part of BNX2 and CNIC driver
re-branding effort.

Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
---
 drivers/net/ethernet/broadcom/Kconfig   | 8 ++++----
 drivers/net/ethernet/broadcom/bnx2.c    | 8 ++++----
 drivers/net/ethernet/broadcom/bnx2.h    | 4 ++--
 drivers/net/ethernet/broadcom/bnx2_fw.h | 4 ++--
 drivers/net/ethernet/broadcom/cnic.c    | 6 +++---
 drivers/net/ethernet/broadcom/cnic_if.h | 4 ++--
 6 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index c3e260c..7849dd1 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -72,12 +72,12 @@ config BCMGENET
 	  Broadcom BCM7xxx Set Top Box family chipset.
 
 config BNX2
-	tristate "QLogic NetXtremeII support"
+	tristate "QLogic bnx2 support"
 	depends on PCI
 	select CRC32
 	select FW_LOADER
 	---help---
-	  This driver supports QLogic NetXtremeII gigabit Ethernet cards.
+	  This driver supports QLogic bnx2 gigabit Ethernet cards.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called bnx2.  This is recommended.
@@ -88,8 +88,8 @@ config CNIC
 	select BNX2
 	select UIO
 	---help---
-	  This driver supports offload features of QLogic NetXtremeII
-	  gigabit Ethernet cards.
+	  This driver supports offload features of QLogic bnx2 gigabit
+	  Ethernet cards.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called cnic.  This is recommended.
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 823d01c..2305de2 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -1,7 +1,7 @@
-/* bnx2.c: QLogic NX2 network driver.
+/* bnx2.c: QLogic bnx2 network driver.
  *
  * Copyright (c) 2004-2014 Broadcom Corporation
- * Copyright (c) 2014 QLogic Corporation
+ * Copyright (c) 2014-2015 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -72,10 +72,10 @@
 #define TX_TIMEOUT  (5*HZ)
 
 static char version[] =
-	"QLogic NetXtreme II Gigabit Ethernet Driver " DRV_MODULE_NAME " v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
+	"QLogic " DRV_MODULE_NAME " Gigabit Ethernet Driver v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com>");
-MODULE_DESCRIPTION("QLogic NetXtreme II BCM5706/5708/5709/5716 Driver");
+MODULE_DESCRIPTION("QLogic BCM5706/5708/5709/5716 Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_MODULE_VERSION);
 MODULE_FIRMWARE(FW_MIPS_FILE_06);
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 28df35d..f92f76c 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -1,7 +1,7 @@
-/* bnx2.h: QLogic NX2 network driver.
+/* bnx2.h: QLogic bnx2 network driver.
  *
  * Copyright (c) 2004-2014 Broadcom Corporation
- * Copyright (c) 2014 QLogic Corporation
+ * Copyright (c) 2014-2015 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/bnx2_fw.h b/drivers/net/ethernet/broadcom/bnx2_fw.h
index 7db79c2..b0f2cca 100644
--- a/drivers/net/ethernet/broadcom/bnx2_fw.h
+++ b/drivers/net/ethernet/broadcom/bnx2_fw.h
@@ -1,7 +1,7 @@
-/* bnx2_fw.h: QLogic NX2 network driver.
+/* bnx2_fw.h: QLogic bnx2 network driver.
  *
  * Copyright (c) 2004, 2005, 2006, 2007 Broadcom Corporation
- * Copyright (c) 2014 QLogic Corporation
+ * Copyright (c) 2014-2015 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index f05fab6..17c145f 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1,7 +1,7 @@
 /* cnic.c: QLogic CNIC core network driver.
  *
  * Copyright (c) 2006-2014 Broadcom Corporation
- * Copyright (c) 2014 QLogic Corporation
+ * Copyright (c) 2014-2015 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -58,11 +58,11 @@
 #define CNIC_MODULE_NAME	"cnic"
 
 static char version[] =
-	"QLogic NetXtreme II CNIC Driver " CNIC_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
+	"QLogic " CNIC_MODULE_NAME "Driver v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com> and John(Zongxi) "
 	      "Chen (zongxi@broadcom.com");
-MODULE_DESCRIPTION("QLogic NetXtreme II CNIC Driver");
+MODULE_DESCRIPTION("QLogic cnic Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(CNIC_MODULE_VERSION);
 
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 8bb36c1..7fe0b64 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -1,7 +1,7 @@
-/* cnic_if.h: QLogic CNIC core network driver.
+/* cnic_if.h: QLogic cnic core network driver.
  *
  * Copyright (c) 2006-2014 Broadcom Corporation
- * Copyright (c) 2014 QLogic Corporation
+ * Copyright (c) 2014-2015 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.8.2.3
