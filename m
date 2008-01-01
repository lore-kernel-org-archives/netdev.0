From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 01/26] atl1: relocate atl1 driver to /drivers/net/atlx
Date: Mon, 31 Dec 2007 20:22:28 -0600
Message-ID: <1199154173-4058-2-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>,
	Chris Snook <csnook@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:37907 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbYAACXG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:23:06 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
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
index 0e5fde4..14acf84 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -13,7 +13,7 @@ obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_EHEA) += ehea/
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
1.5.3.3

