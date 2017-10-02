From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: [PATCH v3 04/19] thunderbolt: Move enum tb_cfg_pkg_type to thunderbolt.h
Date: Mon,  2 Oct 2017 13:38:31 +0300
Message-ID: <20171002103846.64602-5-mika.westerberg@linux.intel.com>
References: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Mika Westerberg <mika.westerberg@linux.intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171002103846.64602-1-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These will be needed by Thunderbolt services when sending and receiving
XDomain control messages. While there change TB_CFG_PKG_PREPARE_TO_SLEEP
value to be decimal in order to be consistent with other members.

Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
Reviewed-by: Michael Jamet <michael.jamet@intel.com>
Reviewed-by: Yehezkel Bernat <yehezkel.bernat@intel.com>
Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/thunderbolt/ctl.h     |  1 +
 drivers/thunderbolt/tb_msgs.h | 17 -----------------
 include/linux/thunderbolt.h   | 17 +++++++++++++++++
 3 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/thunderbolt/ctl.h b/drivers/thunderbolt/ctl.h
index 36fd28b1c1c5..d0f21e1e0b8b 100644
--- a/drivers/thunderbolt/ctl.h
+++ b/drivers/thunderbolt/ctl.h
@@ -8,6 +8,7 @@
 #define _TB_CFG
 
 #include <linux/kref.h>
+#include <linux/thunderbolt.h>
 
 #include "nhi.h"
 #include "tb_msgs.h"
diff --git a/drivers/thunderbolt/tb_msgs.h b/drivers/thunderbolt/tb_msgs.h
index f3adf58a40ce..f2b2550cd97c 100644
--- a/drivers/thunderbolt/tb_msgs.h
+++ b/drivers/thunderbolt/tb_msgs.h
@@ -15,23 +15,6 @@
 #include <linux/types.h>
 #include <linux/uuid.h>
 
-enum tb_cfg_pkg_type {
-	TB_CFG_PKG_READ = 1,
-	TB_CFG_PKG_WRITE = 2,
-	TB_CFG_PKG_ERROR = 3,
-	TB_CFG_PKG_NOTIFY_ACK = 4,
-	TB_CFG_PKG_EVENT = 5,
-	TB_CFG_PKG_XDOMAIN_REQ = 6,
-	TB_CFG_PKG_XDOMAIN_RESP = 7,
-	TB_CFG_PKG_OVERRIDE = 8,
-	TB_CFG_PKG_RESET = 9,
-	TB_CFG_PKG_ICM_EVENT = 10,
-	TB_CFG_PKG_ICM_CMD = 11,
-	TB_CFG_PKG_ICM_RESP = 12,
-	TB_CFG_PKG_PREPARE_TO_SLEEP = 0xd,
-
-};
-
 enum tb_cfg_space {
 	TB_CFG_HOPS = 0,
 	TB_CFG_PORT = 1,
diff --git a/include/linux/thunderbolt.h b/include/linux/thunderbolt.h
index 96561c1265ae..b512b1e2b4f2 100644
--- a/include/linux/thunderbolt.h
+++ b/include/linux/thunderbolt.h
@@ -1,6 +1,7 @@
 /*
  * Thunderbolt service API
  *
+ * Copyright (C) 2014 Andreas Noever <andreas.noever@gmail.com>
  * Copyright (C) 2017, Intel Corporation
  * Authors: Michael Jamet <michael.jamet@intel.com>
  *          Mika Westerberg <mika.westerberg@linux.intel.com>
@@ -16,6 +17,22 @@
 #include <linux/list.h>
 #include <linux/uuid.h>
 
+enum tb_cfg_pkg_type {
+	TB_CFG_PKG_READ = 1,
+	TB_CFG_PKG_WRITE = 2,
+	TB_CFG_PKG_ERROR = 3,
+	TB_CFG_PKG_NOTIFY_ACK = 4,
+	TB_CFG_PKG_EVENT = 5,
+	TB_CFG_PKG_XDOMAIN_REQ = 6,
+	TB_CFG_PKG_XDOMAIN_RESP = 7,
+	TB_CFG_PKG_OVERRIDE = 8,
+	TB_CFG_PKG_RESET = 9,
+	TB_CFG_PKG_ICM_EVENT = 10,
+	TB_CFG_PKG_ICM_CMD = 11,
+	TB_CFG_PKG_ICM_RESP = 12,
+	TB_CFG_PKG_PREPARE_TO_SLEEP = 13,
+};
+
 /**
  * struct tb_property_dir - XDomain property directory
  * @uuid: Directory UUID or %NULL if root directory
-- 
2.14.2
