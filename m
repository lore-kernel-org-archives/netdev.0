From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 2/3] cnic: Rebranding cnic driver.
Date: Mon, 23 Jun 2014 15:10:34 -0400
Message-ID: <1403550635-19700-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1403550635-19700-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52753 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756725AbaFWTl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 15:41:27 -0400
In-Reply-To: <1403550635-19700-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o QLogic has acquired the NetXtremeII products and drivers from Broadcom.
  This patch re-brands cnic driver as a QLogic driver
---
 drivers/net/ethernet/broadcom/Kconfig     |    4 ++--
 drivers/net/ethernet/broadcom/cnic.c      |   10 ++++++----
 drivers/net/ethernet/broadcom/cnic.h      |    3 ++-
 drivers/net/ethernet/broadcom/cnic_defs.h |    3 ++-
 drivers/net/ethernet/broadcom/cnic_if.h   |    3 ++-
 5 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 0bde471..7dcfb19 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -83,12 +83,12 @@ config BNX2
 	  will be called bnx2.  This is recommended.
 
 config CNIC
-	tristate "Broadcom CNIC support"
+	tristate "QLogic CNIC support"
 	depends on PCI
 	select BNX2
 	select UIO
 	---help---
-	  This driver supports offload features of Broadcom NetXtremeII
+	  This driver supports offload features of QLogic NetXtremeII
 	  gigabit Ethernet cards.
 
 	  To compile this driver as a module, choose M here: the module
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index a4b25bc..aaa17b9 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1,13 +1,15 @@
-/* cnic.c: Broadcom CNIC core network driver.
+/* cnic.c: QLogic CNIC core network driver.
  *
  * Copyright (c) 2006-2014 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation.
  *
  * Original skeleton written by: John(Zongxi) Chen (zongxi@broadcom.com)
- * Modified and maintained by: Michael Chan <mchan@broadcom.com>
+ * Previously modified and maintained by: Michael Chan <mchan@broadcom.com>
+ * Maintained By: Dept-HSGLinuxNICDev@qlogic.com
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -56,11 +58,11 @@
 #define CNIC_MODULE_NAME	"cnic"
 
 static char version[] =
-	"Broadcom NetXtreme II CNIC Driver " CNIC_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
+	"QLogic NetXtreme II CNIC Driver " CNIC_MODULE_NAME " v" CNIC_MODULE_VERSION " (" CNIC_MODULE_RELDATE ")\n";
 
 MODULE_AUTHOR("Michael Chan <mchan@broadcom.com> and John(Zongxi) "
 	      "Chen (zongxi@broadcom.com");
-MODULE_DESCRIPTION("Broadcom NetXtreme II CNIC Driver");
+MODULE_DESCRIPTION("QLogic NetXtreme II CNIC Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(CNIC_MODULE_VERSION);
 
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index d535ae4..4baea81 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -1,6 +1,7 @@
-/* cnic.h: Broadcom CNIC core network driver.
+/* cnic.h: QLogic CNIC core network driver.
  *
  * Copyright (c) 2006-2014 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
index dcbca69..b384997 100644
--- a/drivers/net/ethernet/broadcom/cnic_defs.h
+++ b/drivers/net/ethernet/broadcom/cnic_defs.h
@@ -1,7 +1,8 @@
 
-/* cnic.c: Broadcom CNIC core network driver.
+/* cnic.c: QLogic CNIC core network driver.
  *
  * Copyright (c) 2006-2014 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 5f4d557..8bb36c1 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -1,6 +1,7 @@
-/* cnic_if.h: Broadcom CNIC core network driver.
+/* cnic_if.h: QLogic CNIC core network driver.
  *
  * Copyright (c) 2006-2014 Broadcom Corporation
+ * Copyright (c) 2014 QLogic Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
-- 
1.7.9.5
