From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/25] drivers/net/(intel): Use static const
	char arrays
Date: Mon, 13 Sep 2010 12:47:48 -0700
Message-ID: <505f86db1a5ac28f961d5f541c90c99e00bdfc52.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1284406638.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000/e1000.h          |    2 +-
 drivers/net/e1000/e1000_main.c     |    4 ++--
 drivers/net/e1000e/e1000.h         |    2 +-
 drivers/net/e1000e/netdev.c        |    2 +-
 drivers/net/igb/igb.h              |    4 ++--
 drivers/net/igb/igb_main.c         |    4 ++--
 drivers/net/igbvf/igbvf.h          |    2 +-
 drivers/net/igbvf/netdev.c         |    2 +-
 drivers/net/ixgb/ixgb.h            |    2 +-
 drivers/net/ixgb/ixgb_main.c       |    2 +-
 drivers/net/ixgbe/ixgbe.h          |    2 +-
 drivers/net/ixgbe/ixgbe_main.c     |    4 ++--
 drivers/net/ixgbevf/ixgbevf.h      |    2 +-
 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 14 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 99288b9..6a7a7cf 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -339,7 +339,7 @@ extern struct net_device *e1000_get_hw_dev(struct e1000_hw *hw);
 #define e_dev_err(format, arg...) \
 	dev_err(&adapter->pdev->dev, format, ## arg)
 
-extern char e1000_driver_name[];
+extern const char e1000_driver_name[];
 extern const char e1000_driver_version[];
 
 extern int e1000_up(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 17f5867..35ea780 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -29,8 +29,8 @@
 #include "e1000.h"
 #include <net/ip6_checksum.h>
 
-char e1000_driver_name[] = "e1000";
-static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
+const char e1000_driver_name[] = "e1000";
+static const char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #define DRV_VERSION "7.3.21-k6-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index f9a31c8..5929eb3 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -446,7 +446,7 @@ enum latency_range {
 	latency_invalid = 255
 };
 
-extern char e1000e_driver_name[];
+extern const char e1000e_driver_name[];
 extern const char e1000e_driver_version[];
 
 extern void e1000e_check_options(struct e1000_adapter *adapter);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c9b66f4..51c80a3 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -55,7 +55,7 @@
 #define DRV_EXTRAVERSION "-k2"
 
 #define DRV_VERSION "1.2.7" DRV_EXTRAVERSION
-char e1000e_driver_name[] = "e1000e";
+const char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
 static const struct e1000_info *e1000_info_tbl[] = {
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 44e0ff1..4f0a81e 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -337,8 +337,8 @@ enum igb_boards {
 	board_82575,
 };
 
-extern char igb_driver_name[];
-extern char igb_driver_version[];
+extern const char igb_driver_name[];
+extern const char igb_driver_version[];
 
 extern int igb_up(struct igb_adapter *);
 extern void igb_down(struct igb_adapter *);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 3adef1e..5c5ccfc 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -51,8 +51,8 @@
 #include "igb.h"
 
 #define DRV_VERSION "2.1.0-k2"
-char igb_driver_name[] = "igb";
-char igb_driver_version[] = DRV_VERSION;
+const char igb_driver_name[] = "igb";
+const char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
 				"Intel(R) Gigabit Ethernet Network Driver";
 static const char igb_copyright[] = "Copyright (c) 2007-2009 Intel Corporation.";
diff --git a/drivers/net/igbvf/igbvf.h b/drivers/net/igbvf/igbvf.h
index debeee2..8f0b3ef 100644
--- a/drivers/net/igbvf/igbvf.h
+++ b/drivers/net/igbvf/igbvf.h
@@ -309,7 +309,7 @@ enum latency_range {
 	latency_invalid = 255
 };
 
-extern char igbvf_driver_name[];
+extern const char igbvf_driver_name[];
 extern const char igbvf_driver_version[];
 
 extern void igbvf_check_options(struct igbvf_adapter *);
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index c7fab80..a578fe5 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -46,7 +46,7 @@
 #include "igbvf.h"
 
 #define DRV_VERSION "1.0.0-k0"
-char igbvf_driver_name[] = "igbvf";
+const char igbvf_driver_name[] = "igbvf";
 const char igbvf_driver_version[] = DRV_VERSION;
 static struct pm_qos_request_list igbvf_driver_pm_qos_req;
 static const char igbvf_driver_string[] =
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 521c0c7..ef76e5e 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -204,7 +204,7 @@ enum ixgb_state_t {
 /* Exported from other modules */
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
 extern void ixgb_set_ethtool_ops(struct net_device *netdev);
-extern char ixgb_driver_name[];
+extern const char ixgb_driver_name[];
 extern const char ixgb_driver_version[];
 
 extern int ixgb_up(struct ixgb_adapter *adapter);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c2f6e71..bffb164 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -30,7 +30,7 @@
 
 #include "ixgb.h"
 
-char ixgb_driver_name[] = "ixgb";
+const char ixgb_driver_name[] = "ixgb";
 static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 
 #define DRIVERNAPI "-NAPI"
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 5cebc37..f397251 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -441,7 +441,7 @@ extern int ixgbe_copy_dcb_cfg(struct ixgbe_dcb_config *src_dcb_cfg,
                               int tc_max);
 #endif
 
-extern char ixgbe_driver_name[];
+extern const char ixgbe_driver_name[];
 extern const char ixgbe_driver_version[];
 
 extern int ixgbe_up(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3aafe94..9db1c8c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -48,8 +48,8 @@
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"
 
-char ixgbe_driver_name[] = "ixgbe";
-static const char ixgbe_driver_string[] =
+const char ixgbe_driver_name[] = "ixgbe";
+const char ixgbe_driver_string[] =
                               "Intel(R) 10 Gigabit PCI Express Network Driver";
 
 #define DRV_VERSION "2.0.84-k2"
diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index f7015ef..f6c72f1 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -282,7 +282,7 @@ extern struct ixgbevf_info ixgbevf_vf_info;
 extern struct ixgbe_mac_operations ixgbevf_mbx_ops;
 
 /* needed by ethtool.c */
-extern char ixgbevf_driver_name[];
+extern const char ixgbevf_driver_name[];
 extern const char ixgbevf_driver_version[];
 
 extern int ixgbevf_up(struct ixgbevf_adapter *adapter);
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index bdbd26c..eedb5ec 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -47,7 +47,7 @@
 
 #include "ixgbevf.h"
 
-char ixgbevf_driver_name[] = "ixgbevf";
+const char ixgbevf_driver_name[] = "ixgbevf";
 static const char ixgbevf_driver_string[] =
 	"Intel(R) 82599 Virtual Function";
 
-- 
1.7.3.rc1


------------------------------------------------------------------------------
Start uncovering the many advantages of virtual appliances
and start using them to simplify application deployment and
accelerate your shift to cloud computing
http://p.sf.net/sfu/novell-sfdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
