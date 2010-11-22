From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Subject: [PATCH 1/2] pch_gbe dreiver: chang author
Date: Mon, 22 Nov 2010 14:58:37 +0900
Message-ID: <4CEA068D.3070900@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	John Linn <john.linn@xilinx.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Greg Rose <gregory.v.rose@intel.com>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Masayuki Ohtake <masa-korg@dsn.okisemi.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	"Ewe, Kok Howg" <kok.howg.ewe@intel.com>
To: "Dr. David Alan Gilbert" <linux@treblig.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:20981 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083Ab0KVF6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Nov 2010 00:58:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver's AUTHOR was changed to "Toshiharu Okada" from "Masayuki Ohtake".
I update the Kconfig, renamed "Topcliff" to "EG20T".

Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
---
 drivers/net/Kconfig                |    6 +++---
 drivers/net/pch_gbe/pch_gbe_main.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f6668cd..a445a04 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2543,10 +2543,10 @@ config PCH_GBE
 	depends on PCI
 	select MII
 	---help---
-	  This is a gigabit ethernet driver for Topcliff PCH.
-	  Topcliff PCH is the platform controller hub that is used in Intel's
+	  This is a gigabit ethernet driver for EG20T PCH.
+	  EG20T PCH is the platform controller hub that is used in Intel's
 	  general embedded platform.
-	  Topcliff PCH has Gigabit Ethernet interface.
+	  EG20T PCH has Gigabit Ethernet interface.
 	  Using this interface, it is able to access system devices connected
 	  to Gigabit Ethernet.
 	  This driver enables Gigabit Ethernet function.
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 472056b..03a1d28 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 1999 - 2010 Intel Corporation.
- * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
  *
  * This code was derived from the Intel e1000e Linux driver.
  *
@@ -2464,8 +2464,8 @@ static void __exit pch_gbe_exit_module(void)
 module_init(pch_gbe_init_module);
 module_exit(pch_gbe_exit_module);
 
-MODULE_DESCRIPTION("OKI semiconductor PCH Gigabit ethernet Driver");
-MODULE_AUTHOR("OKI semiconductor, <masa-korg@dsn.okisemi.com>");
+MODULE_DESCRIPTION("EG20T PCH Gigabit ethernet Driver");
+MODULE_AUTHOR("OKI SEMICONDUCTOR, <toshiharu-linux@dsn.okisemi.com>");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, pch_gbe_pcidev_id);
-- 
1.6.2.5
