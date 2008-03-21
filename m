From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/9] ixgb: move externs out of .c files
Date: Fri, 21 Mar 2008 11:06:42 -0700
Message-ID: <20080321180642.24164.72597.stgit@localhost.localdomain>
References: <20080321180625.24164.46137.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080321180625.24164.46137.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h         |   10 ++++++++++
 drivers/net/ixgb/ixgb_ethtool.c |    9 ---------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index fad4e99..a95ab55 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -212,4 +212,14 @@ extern void ixgb_set_ethtool_ops(struct net_device *netdev);
 extern char ixgb_driver_name[];
 extern const char ixgb_driver_version[];
 
+extern int ixgb_up(struct ixgb_adapter *adapter);
+extern void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
+extern void ixgb_reset(struct ixgb_adapter *adapter);
+extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
+extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
+extern void ixgb_update_stats(struct ixgb_adapter *adapter);
+
+
 #endif /* _IXGB_H_ */
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 5d61c2e..45ddf80 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -32,15 +32,6 @@
 
 #include <asm/uaccess.h>
 
-extern int ixgb_up(struct ixgb_adapter *adapter);
-extern void ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog);
-extern void ixgb_reset(struct ixgb_adapter *adapter);
-extern int ixgb_setup_rx_resources(struct ixgb_adapter *adapter);
-extern int ixgb_setup_tx_resources(struct ixgb_adapter *adapter);
-extern void ixgb_free_rx_resources(struct ixgb_adapter *adapter);
-extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
-extern void ixgb_update_stats(struct ixgb_adapter *adapter);
-
 #define IXGB_ALL_RAR_ENTRIES 16
 
 struct ixgb_stats {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
