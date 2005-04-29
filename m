From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 7/11] ixgb: Support for ethtool -d
Date: Thu, 28 Apr 2005 19:04:07 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281858060.28003-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

ixgb support for ethtool -d

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_ethtool.c	2005-04-05 23:06:36.331229608 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_ethtool.c	2005-04-05 23:06:38.037970144 -0700
@@ -252,7 +252,9 @@ ixgb_get_regs(struct net_device *netdev,
 	uint32_t *reg_start = reg;
 	uint8_t i;
 
-	regs->version = (adapter->hw.device_id << 16) | adapter->hw.subsystem_id;
+	/* the 1 (one) below indicates an attempt at versioning, if the
+	 * interface in ethtool or the driver this 1 should be incremented */
+	regs->version = (1<<24) | hw->revision_id << 16 | hw->device_id;
 
 	/* General Registers */
 	*reg++ = IXGB_READ_REG(hw, CTRL0);	/*   0 */
