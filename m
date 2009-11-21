From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/23] e1000e: cleanup redundant #include's
Date: Sat, 21 Nov 2009 01:24:48 -0800
Message-ID: <20091121092447.5715.80125.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:50194
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbZKUJY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:24:58 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    4 ----
 drivers/net/e1000e/e1000.h   |    1 +
 drivers/net/e1000e/es2lan.c  |    5 -----
 drivers/net/e1000e/ich8lan.c |    5 -----
 drivers/net/e1000e/lib.c     |    5 -----
 5 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index d1e0563..407637f 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -43,10 +43,6 @@
  * 82583V Gigabit Network Connection
  */
 
-#include <linux/netdevice.h>
-#include <linux/delay.h>
-#include <linux/pci.h>
-
 #include "e1000.h"
 
 #define ID_LED_RESERVED_F746 0xF746
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index a6c6803..ac5d855 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -36,6 +36,7 @@
 #include <linux/workqueue.h>
 #include <linux/io.h>
 #include <linux/netdevice.h>
+#include <linux/pci.h>
 
 #include "hw.h"
 
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index ae5d736..6fd46f5 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -31,11 +31,6 @@
  * 80003ES2LAN Gigabit Ethernet Controller (Serdes)
  */
 
-#include <linux/netdevice.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
-#include <linux/pci.h>
-
 #include "e1000.h"
 
 #define E1000_KMRNCTRLSTA_OFFSET_FIFO_CTRL	 0x00
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index bd9002e..bef5e33 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -54,11 +54,6 @@
  * 82578DC Gigabit Network Connection
  */
 
-#include <linux/netdevice.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
-#include <linux/pci.h>
-
 #include "e1000.h"
 
 #define ICH_FLASH_GFPREG		0x0000
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 99ba2b8..5a670a2 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -26,11 +26,6 @@
 
 *******************************************************************************/
 
-#include <linux/netdevice.h>
-#include <linux/ethtool.h>
-#include <linux/delay.h>
-#include <linux/pci.h>
-
 #include "e1000.h"
 
 enum e1000_mng_mode {

