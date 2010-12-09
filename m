From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 3/7] e1000e: cleanup: simplify E1000_ALL_* defines
Date: Thu,  9 Dec 2010 02:40:53 +0000
Message-ID: <1291862457-16671-4-git-send-email-asbjorn__6071.65035694397$1291863060$gmane$org@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.asbjorn.biz ([217.195.185.3]:57623 "EHLO mail.asbjorn.biz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754955Ab0LICu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Dec 2010 21:50:26 -0500
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanup E1000_ALL_* so that each of them can fit on one line,
by reusing each other instead of solely using combinations of
ADVERTISE_* as defined right above it.

This fixes 2 checkpatch errors.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/defines.h |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 2b969c8..10760be 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -263,14 +263,11 @@
 #define ADVERTISE_1000_FULL               0x0020
 
 /* 1000/H is not supported, nor spec-compliant. */
-#define E1000_ALL_SPEED_DUPLEX ( ADVERTISE_10_HALF |   ADVERTISE_10_FULL | \
-				ADVERTISE_100_HALF |  ADVERTISE_100_FULL | \
-						     ADVERTISE_1000_FULL)
-#define E1000_ALL_NOT_GIG      ( ADVERTISE_10_HALF |   ADVERTISE_10_FULL | \
-				ADVERTISE_100_HALF |  ADVERTISE_100_FULL)
+#define E1000_ALL_10_SPEED     (ADVERTISE_10_HALF  |   ADVERTISE_10_FULL)
 #define E1000_ALL_100_SPEED    (ADVERTISE_100_HALF |  ADVERTISE_100_FULL)
-#define E1000_ALL_10_SPEED      (ADVERTISE_10_HALF |   ADVERTISE_10_FULL)
-#define E1000_ALL_HALF_DUPLEX   (ADVERTISE_10_HALF |  ADVERTISE_100_HALF)
+#define E1000_ALL_HALF_DUPLEX  (ADVERTISE_10_HALF  |  ADVERTISE_100_HALF)
+#define E1000_ALL_NOT_GIG      (E1000_ALL_10_SPEED | E1000_ALL_100_SPEED)
+#define E1000_ALL_SPEED_DUPLEX (E1000_ALL_NOT_GIG  | ADVERTISE_1000_FULL)
 
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT   E1000_ALL_SPEED_DUPLEX
 
-- 
1.7.2.3

