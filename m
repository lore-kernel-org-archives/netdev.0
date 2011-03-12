From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 18/21] ixgbe: correct typo in define name
Date: Sat, 12 Mar 2011 04:20:25 -0800
Message-ID: <1299932428-3114-19-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753991Ab1CLMU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:59 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

VF Free Running Timer register name missing an F.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ethtool.c |    4 ++--
 drivers/net/ixgbevf/regs.h    |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbevf/ethtool.c b/drivers/net/ixgbevf/ethtool.c
index fa29b3c..0563ab2 100644
--- a/drivers/net/ixgbevf/ethtool.c
+++ b/drivers/net/ixgbevf/ethtool.c
@@ -172,7 +172,7 @@ static char *ixgbevf_reg_names[] = {
 	"IXGBE_VFSTATUS",
 	"IXGBE_VFLINKS",
 	"IXGBE_VFRXMEMWRAP",
-	"IXGBE_VFRTIMER",
+	"IXGBE_VFFRTIMER",
 	"IXGBE_VTEICR",
 	"IXGBE_VTEICS",
 	"IXGBE_VTEIMS",
@@ -240,7 +240,7 @@ static void ixgbevf_get_regs(struct net_device *netdev,
 	regs_buff[1] = IXGBE_READ_REG(hw, IXGBE_VFSTATUS);
 	regs_buff[2] = IXGBE_READ_REG(hw, IXGBE_VFLINKS);
 	regs_buff[3] = IXGBE_READ_REG(hw, IXGBE_VFRXMEMWRAP);
-	regs_buff[4] = IXGBE_READ_REG(hw, IXGBE_VFRTIMER);
+	regs_buff[4] = IXGBE_READ_REG(hw, IXGBE_VFFRTIMER);
 
 	/* Interrupt */
 	/* don't read EICR because it can clear interrupt causes, instead
diff --git a/drivers/net/ixgbevf/regs.h b/drivers/net/ixgbevf/regs.h
index fb80ca1..189200e 100644
--- a/drivers/net/ixgbevf/regs.h
+++ b/drivers/net/ixgbevf/regs.h
@@ -31,7 +31,7 @@
 #define IXGBE_VFCTRL           0x00000
 #define IXGBE_VFSTATUS         0x00008
 #define IXGBE_VFLINKS          0x00010
-#define IXGBE_VFRTIMER         0x00048
+#define IXGBE_VFFRTIMER        0x00048
 #define IXGBE_VFRXMEMWRAP      0x03190
 #define IXGBE_VTEICR           0x00100
 #define IXGBE_VTEICS           0x00104
-- 
1.7.4

