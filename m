From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/10] atheros: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:32 -0700
Message-ID: <b7bf26665e0378a3ec9d4450daf60dc115f75e49.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h |  6 +++---
 drivers/net/ethernet/atheros/atl1e/atl1e.h | 12 ++++++------
 drivers/net/ethernet/atheros/atlx/atl2.h   |  2 +-
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index 0f05565..7f9369a 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -600,7 +600,7 @@ struct atl1c_adapter {
 extern char atl1c_driver_name[];
 extern char atl1c_driver_version[];
 
-extern void atl1c_reinit_locked(struct atl1c_adapter *adapter);
-extern s32 atl1c_reset_hw(struct atl1c_hw *hw);
-extern void atl1c_set_ethtool_ops(struct net_device *netdev);
+void atl1c_reinit_locked(struct atl1c_adapter *adapter);
+s32 atl1c_reset_hw(struct atl1c_hw *hw);
+void atl1c_set_ethtool_ops(struct net_device *netdev);
 #endif /* _ATL1C_H_ */
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e.h b/drivers/net/ethernet/atheros/atl1e/atl1e.h
index b5fd934..1b0fe2d 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e.h
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e.h
@@ -499,10 +499,10 @@ struct atl1e_adapter {
 extern char atl1e_driver_name[];
 extern char atl1e_driver_version[];
 
-extern void atl1e_check_options(struct atl1e_adapter *adapter);
-extern int atl1e_up(struct atl1e_adapter *adapter);
-extern void atl1e_down(struct atl1e_adapter *adapter);
-extern void atl1e_reinit_locked(struct atl1e_adapter *adapter);
-extern s32 atl1e_reset_hw(struct atl1e_hw *hw);
-extern void atl1e_set_ethtool_ops(struct net_device *netdev);
+void atl1e_check_options(struct atl1e_adapter *adapter);
+int atl1e_up(struct atl1e_adapter *adapter);
+void atl1e_down(struct atl1e_adapter *adapter);
+void atl1e_reinit_locked(struct atl1e_adapter *adapter);
+s32 atl1e_reset_hw(struct atl1e_hw *hw);
+void atl1e_set_ethtool_ops(struct net_device *netdev);
 #endif /* _ATL1_E_H_ */
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.h b/drivers/net/ethernet/atheros/atlx/atl2.h
index 3ebe19f..2f27d4c 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.h
+++ b/drivers/net/ethernet/atheros/atlx/atl2.h
@@ -42,7 +42,7 @@
 #include "atlx.h"
 
 #ifdef ETHTOOL_OPS_COMPAT
-extern int ethtool_ioctl(struct ifreq *ifr);
+int ethtool_ioctl(struct ifreq *ifr);
 #endif
 
 #define PCI_COMMAND_REGISTER	PCI_COMMAND
-- 
1.8.1.2.459.gbcd45b4.dirty
