From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 01/10] atl1: relocate atl1 driver to /drivers/net/atlx
Date: Sat,  2 Feb 2008 19:50:03 -0600
Message-ID: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([204.127.217.103]:45971 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbYBCBuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for a future Atheros L2 NIC driver (called atl2), relocate
the atl1 driver into a new /drivers/net/atlx directory that will ultimately
be shared with the future atl2 driver.

Signed-off-by: Chris Snook <csnook@redhat.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/Makefile                      |    2 +-
 drivers/net/{atl1 => atlx}/Makefile       |    0 
 drivers/net/{atl1 => atlx}/atl1.h         |    0 
 drivers/net/{atl1 => atlx}/atl1_ethtool.c |    0 
 drivers/net/{atl1 => atlx}/atl1_hw.c      |    0 
 drivers/net/{atl1 => atlx}/atl1_hw.h      |    0 
 drivers/net/{atl1 => atlx}/atl1_main.c    |    0 
 drivers/net/{atl1 => atlx}/atl1_param.c   |    0 
 8 files changed, 1 insertions(+), 1 deletions(-)
 rename drivers/net/{atl1 => atlx}/Makefile (100%)
 rename drivers/net/{atl1 => atlx}/atl1.h (100%)
 rename drivers/net/{atl1 => atlx}/atl1_ethtool.c (100%)
 rename drivers/net/{atl1 => atlx}/atl1_hw.c (100%)
 rename drivers/net/{atl1 => atlx}/atl1_hw.h (100%)
 rename drivers/net/{atl1 => atlx}/atl1_main.c (100%)
 rename drivers/net/{atl1 => atlx}/atl1_param.c (100%)

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 9fc7794..ae11d5e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -15,7 +15,7 @@ obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
-obj-$(CONFIG_ATL1) += atl1/
+obj-$(CONFIG_ATL1) += atlx/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_TEHUTI) += tehuti.o
 
diff --git a/drivers/net/atl1/Makefile b/drivers/net/atlx/Makefile
similarity index 100%
rename from drivers/net/atl1/Makefile
rename to drivers/net/atlx/Makefile
diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atlx/atl1.h
similarity index 100%
rename from drivers/net/atl1/atl1.h
rename to drivers/net/atlx/atl1.h
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atlx/atl1_ethtool.c
similarity index 100%
rename from drivers/net/atl1/atl1_ethtool.c
rename to drivers/net/atlx/atl1_ethtool.c
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atlx/atl1_hw.c
similarity index 100%
rename from drivers/net/atl1/atl1_hw.c
rename to drivers/net/atlx/atl1_hw.c
diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atlx/atl1_hw.h
similarity index 100%
rename from drivers/net/atl1/atl1_hw.h
rename to drivers/net/atlx/atl1_hw.h
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atlx/atl1_main.c
similarity index 100%
rename from drivers/net/atl1/atl1_main.c
rename to drivers/net/atlx/atl1_main.c
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atlx/atl1_param.c
similarity index 100%
rename from drivers/net/atl1/atl1_param.c
rename to drivers/net/atlx/atl1_param.c
-- 
1.5.3.8

