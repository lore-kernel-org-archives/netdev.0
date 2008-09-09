From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 4/4] atlx: update build files for atl2
Date: Tue, 9 Sep 2008 02:24:41 -0400
Message-ID: <20080909062441.GD18425@file.rdu.redhat.com>
References: <20080909061247.GA17834@file.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, jcliburn@gmail.com
To: jeff@garzik.org, netdev@vger.kernel.org,
	atl2-test@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753813AbYIIGZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:25:30 -0400
Content-Disposition: inline
In-Reply-To: <20080909061247.GA17834@file.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Snook <csnook@redhat.com>

Add the Kconfig and Makefile entries for atl2.  Also remove the EXPERIMENTAL
label from atl1, as it is now quite mature.

Signed-off-by: Chris Snook <csnook@redhat.com>

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4182cf..1c6150d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1884,6 +1884,17 @@ config NE_H8300
 	  Say Y here if you want to use the NE2000 compatible
 	  controller on the Renesas H8/300 processor.
 
+config ATL2
+	tristate "Atheros L2 Fast Ethernet support"
+	depends on PCI
+	select CRC32
+	select MII
+	help
+	  This driver supports the Atheros L2 fast ethernet adapter.
+
+	  To compile this driver as a module, choose M here.  The module
+	  will be called atl2.
+
 source "drivers/net/fec_8xx/Kconfig"
 source "drivers/net/fs_enet/Kconfig"
 
@@ -2342,12 +2353,12 @@ config QLA3XXX
 	  will be called qla3xxx.
 
 config ATL1
-	tristate "Attansic L1 Gigabit Ethernet support (EXPERIMENTAL)"
-	depends on PCI && EXPERIMENTAL
+	tristate "Atheros L1 Gigabit Ethernet support"
+	depends on PCI
 	select CRC32
 	select MII
 	help
-	  This driver supports the Attansic L1 gigabit ethernet adapter.
+	  This driver supports the Atheros L1 gigabit ethernet adapter.
 
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1.
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index dcbfe84..398b883 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atlx/
+obj-$(CONFIG_ATL2) += atlx/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 
diff --git a/drivers/net/atlx/Makefile b/drivers/net/atlx/Makefile
index ca45553..e546aba 100644
--- a/drivers/net/atlx/Makefile
+++ b/drivers/net/atlx/Makefile
@@ -1 +1,2 @@
 obj-$(CONFIG_ATL1)	+= atl1.o
+obj-$(CONFIG_ATL2)	+= atl2.o
