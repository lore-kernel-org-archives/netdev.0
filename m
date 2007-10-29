From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/4] ixgbe: minor sparse fixes
Date: Mon, 29 Oct 2007 10:46:24 -0700
Message-ID: <20071029174624.25245.22619.stgit@localhost.localdomain>
References: <20071029174605.25245.15294.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36119 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756372AbXJ2RyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 13:54:06 -0400
In-Reply-To: <20071029174605.25245.15294.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Make strings const if possible, and fix includes so forward definitions
are seen.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe.h       |    2 +-
 drivers/net/ixgbe/ixgbe_82598.c |    3 +--
 drivers/net/ixgbe/ixgbe_main.c  |    9 +++++----
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index c160a7d..bc51432 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -244,7 +244,7 @@ extern struct ixgbe_info ixgbe_82598EB_info;
 extern struct ixgbe_info ixgbe_82598AT_info;
 
 extern char ixgbe_driver_name[];
-extern char ixgbe_driver_version[];
+extern const char ixgbe_driver_version[];
 
 extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 00ee201..4d64673 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -30,8 +30,7 @@
 #include <linux/delay.h>
 #include <linux/sched.h>
 
-#include "ixgbe_type.h"
-#include "ixgbe_common.h"
+#include "ixgbe.h"
 #include "ixgbe_phy.h"
 
 #define IXGBE_82598_MAX_TX_QUEUES 32
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b75f1c6..00bc525 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -45,12 +45,13 @@
 #include "ixgbe_common.h"
 
 char ixgbe_driver_name[] = "ixgbe";
-static char ixgbe_driver_string[] =
-			"Intel(R) 10 Gigabit PCI Express Network Driver";
+static const char ixgbe_driver_string[] =
+	"Intel(R) 10 Gigabit PCI Express Network Driver";
 
 #define DRV_VERSION "1.1.18"
-char ixgbe_driver_version[] = DRV_VERSION;
-static char ixgbe_copyright[] = "Copyright (c) 1999-2007 Intel Corporation.";
+const char ixgbe_driver_version[] = DRV_VERSION;
+static const char ixgbe_copyright[] =
+	 "Copyright (c) 1999-2007 Intel Corporation.";
 
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598AF]			= &ixgbe_82598AF_info,
