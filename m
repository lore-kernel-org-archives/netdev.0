From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH v2 2/2] can: remove references to berlios mailinglist
Date: Mon, 17 Oct 2011 21:32:00 +0200
Message-ID: <1318879920-25280-3-git-send-email-mkl@pengutronix.de>
References: <1318879920-25280-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>
To: linux-can@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40036 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596Ab1JQTcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 15:32:05 -0400
In-Reply-To: <1318879920-25280-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BerliOS project, which currently hosts our mailinglist, will
close with the end of the year. Now take the chance and remove all
occurrences of the mailinglist address from the source files.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---

Changes since v1:
- remove mailinglist address altogether (tnx David).

 drivers/net/can/at91_can.c        |    2 --
 drivers/net/can/sja1000/sja1000.c |    2 --
 drivers/net/can/sja1000/sja1000.h |    2 --
 drivers/net/can/slcan.c           |    2 --
 drivers/net/can/vcan.c            |    2 --
 include/linux/can.h               |    2 --
 include/linux/can/bcm.h           |    2 --
 include/linux/can/core.h          |    2 --
 include/linux/can/dev.h           |    1 -
 include/linux/can/error.h         |    2 --
 include/linux/can/gw.h            |    2 --
 include/linux/can/netlink.h       |    2 --
 include/linux/can/raw.h           |    2 --
 net/can/af_can.c                  |    2 --
 net/can/af_can.h                  |    2 --
 net/can/bcm.c                     |    2 --
 net/can/gw.c                      |    2 --
 net/can/proc.c                    |    2 --
 net/can/raw.c                     |    2 --
 19 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 121ede6..044ea06 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -8,8 +8,6 @@
  * Public License ("GPL") version 2 as distributed in the 'COPYING'
  * file from the main directory of the linux kernel source.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  *
  * Your platform definition file should specify something like:
  *
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index f501bba..04a3f1b 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -40,8 +40,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/can/sja1000/sja1000.h b/drivers/net/can/sja1000/sja1000.h
index 78bd4ec..23fff06 100644
--- a/drivers/net/can/sja1000/sja1000.h
+++ b/drivers/net/can/sja1000/sja1000.h
@@ -40,8 +40,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef SJA1000_DEV_H
diff --git a/drivers/net/can/slcan.c b/drivers/net/can/slcan.c
index 4b70b7e..a979b00 100644
--- a/drivers/net/can/slcan.c
+++ b/drivers/net/can/slcan.c
@@ -35,8 +35,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index a30b8f4..f93e2d6 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -37,8 +37,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/include/linux/can.h b/include/linux/can.h
index bb047dc..9a19bcb 100644
--- a/include/linux/can.h
+++ b/include/linux/can.h
@@ -8,8 +8,6 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_H
diff --git a/include/linux/can/bcm.h b/include/linux/can/bcm.h
index e96154d..3ebe387 100644
--- a/include/linux/can/bcm.h
+++ b/include/linux/can/bcm.h
@@ -7,8 +7,6 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_BCM_H
diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 5ce6b5d..0ccc1cd 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -8,8 +8,6 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_CORE_H
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index cc0bb49..a0969fc 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -8,7 +8,6 @@
  *
  * Copyright (C) 2008 Wolfgang Grandegger <wg@grandegger.com>
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
  */
 
 #ifndef CAN_DEV_H
diff --git a/include/linux/can/error.h b/include/linux/can/error.h
index 5958074..63e855e 100644
--- a/include/linux/can/error.h
+++ b/include/linux/can/error.h
@@ -7,8 +7,6 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_ERROR_H
diff --git a/include/linux/can/gw.h b/include/linux/can/gw.h
index 5527b54..8e1db18 100644
--- a/include/linux/can/gw.h
+++ b/include/linux/can/gw.h
@@ -7,8 +7,6 @@
  * Copyright (c) 2011 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_GW_H
diff --git a/include/linux/can/netlink.h b/include/linux/can/netlink.h
index 34542d3..14966dd 100644
--- a/include/linux/can/netlink.h
+++ b/include/linux/can/netlink.h
@@ -5,8 +5,6 @@
  *
  * Copyright (c) 2009 Wolfgang Grandegger <wg@grandegger.com>
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_NETLINK_H
diff --git a/include/linux/can/raw.h b/include/linux/can/raw.h
index b2a0f87..781f3a3 100644
--- a/include/linux/can/raw.h
+++ b/include/linux/can/raw.h
@@ -8,8 +8,6 @@
  * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
  * All rights reserved.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef CAN_RAW_H
diff --git a/net/can/af_can.c b/net/can/af_can.c
index d1ff515..0ce2ad0 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -38,8 +38,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/net/can/af_can.h b/net/can/af_can.h
index 34253b8..fd882db 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -35,8 +35,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #ifndef AF_CAN_H
diff --git a/net/can/bcm.c b/net/can/bcm.c
index c84963d..151b773 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -37,8 +37,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/net/can/gw.c b/net/can/gw.c
index ac11407..3d79b12 100644
--- a/net/can/gw.c
+++ b/net/can/gw.c
@@ -37,8 +37,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/net/can/proc.c b/net/can/proc.c
index 0016f73..ba873c3 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -37,8 +37,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
diff --git a/net/can/raw.c b/net/can/raw.c
index dea99a6..cde1b4a 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -37,8 +37,6 @@
  * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
  * DAMAGE.
  *
- * Send feedback to <socketcan-users@lists.berlios.de>
- *
  */
 
 #include <linux/module.h>
-- 
1.7.4.1
