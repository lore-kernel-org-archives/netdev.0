From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 1/4] Staging: octeon: remove unneeded includes
Date: Mon, 15 Feb 2010 12:13:16 -0800
Message-ID: <1266264799-3510-1-git-send-email-ddaney@caviumnetworks.com>
References: <4B79AAA6.60005@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19975 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756315Ab0BOUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:13:33 -0500
In-Reply-To: <4B79AAA6.60005@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-mdio.h  |    1 -
 drivers/staging/octeon/ethernet-rgmii.c |    1 -
 drivers/staging/octeon/ethernet-sgmii.c |    1 -
 drivers/staging/octeon/ethernet-spi.c   |    1 -
 drivers/staging/octeon/ethernet-xaui.c  |    1 -
 drivers/staging/octeon/ethernet.c       |    1 -
 6 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-mdio.h b/drivers/staging/octeon/ethernet-mdio.h
index 55d0614..a417d4f 100644
--- a/drivers/staging/octeon/ethernet-mdio.h
+++ b/drivers/staging/octeon/ethernet-mdio.h
@@ -32,7 +32,6 @@
 #include <linux/ip.h>
 #include <linux/string.h>
 #include <linux/ethtool.h>
-#include <linux/mii.h>
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <net/dst.h>
diff --git a/drivers/staging/octeon/ethernet-rgmii.c b/drivers/staging/octeon/ethernet-rgmii.c
index 3820f1e..f90d46e 100644
--- a/drivers/staging/octeon/ethernet-rgmii.c
+++ b/drivers/staging/octeon/ethernet-rgmii.c
@@ -26,7 +26,6 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/mii.h>
 #include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
diff --git a/drivers/staging/octeon/ethernet-sgmii.c b/drivers/staging/octeon/ethernet-sgmii.c
index 6061d01..2d8589e 100644
--- a/drivers/staging/octeon/ethernet-sgmii.c
+++ b/drivers/staging/octeon/ethernet-sgmii.c
@@ -26,7 +26,6 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/mii.h>
 #include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
diff --git a/drivers/staging/octeon/ethernet-spi.c b/drivers/staging/octeon/ethernet-spi.c
index 00dc0f4..b58b897 100644
--- a/drivers/staging/octeon/ethernet-spi.c
+++ b/drivers/staging/octeon/ethernet-spi.c
@@ -26,7 +26,6 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/mii.h>
 #include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
diff --git a/drivers/staging/octeon/ethernet-xaui.c b/drivers/staging/octeon/ethernet-xaui.c
index ee3dc41..3fca1cc 100644
--- a/drivers/staging/octeon/ethernet-xaui.c
+++ b/drivers/staging/octeon/ethernet-xaui.c
@@ -26,7 +26,6 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
-#include <linux/mii.h>
 #include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 9d63202..5afece0 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -29,7 +29,6 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/delay.h>
 #include <linux/phy.h>
 
 #include <net/dst.h>
-- 
1.6.6

