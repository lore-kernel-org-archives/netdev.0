From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] 68360enet: Remove Kconfig/Makefile references
Date: Sat, 16 Jul 2011 12:33:26 -0700
Message-ID: <1310844806-763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53209 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752181Ab1GPTdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jul 2011 15:33:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

68360enet.c no longer exists, and from the research, it appears that
68360enet.c became fec.c back in 2004.  The Kconfig and Makefile
references were never cleaned up.  This patch removes this "dead"
references.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig  |    7 -------
 drivers/net/Makefile |    1 -
 2 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 17ed4dd..8d0314d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1934,13 +1934,6 @@ config DECLANCE
 	  DEC (now Compaq) based on the AMD Lance chipset, including the
 	  DEPCA series.  (This chipset is better known via the NE2100 cards.)
 
-config 68360_ENET
-	bool "Motorola 68360 ethernet controller"
-	depends on M68360
-	help
-	  Say Y here if you want to use the built-in ethernet controller of
-	  the Motorola 68360 processor.
-
 config FEC
 	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
 	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 86f6c8d..b7622c3 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -127,7 +127,6 @@ obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
 ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
 endif
-obj-$(CONFIG_68360_ENET) += 68360enet.o
 obj-$(CONFIG_WD80x3) += wd.o 8390.o
 obj-$(CONFIG_EL2) += 3c503.o 8390p.o
 obj-$(CONFIG_NE2000) += ne.o 8390p.o
-- 
1.7.6

