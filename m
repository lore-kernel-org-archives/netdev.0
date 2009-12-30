From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Subject: [PATCH] drivers/net/ixgbe/ixgbe_common.c: use %pM to show MAC address
Date: Wed, 30 Dec 2009 13:40:04 -0500
Message-ID: <BD79186B4FD85F4B8E60E381CAEE19090200F642@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David Miller" <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753052AbZL3SkO@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the %pM kernel extension to display the MAC address.

The only difference in the output is that the MAC address is
shown in the usual colon-separated hex notation.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: David S. Miller <davem@davemloft.net>

---

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 688b8ca..1cedb9a 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1278,19 +1278,11 @@ s32 ixgbe_init_rx_addrs_generic(struct ixgbe_hw *hw)
 		/* Get the MAC address from the RAR0 for later reference */
 		hw->mac.ops.get_mac_addr(hw, hw->mac.addr);
 
-		hw_dbg(hw, " Keeping Current RAR0 Addr =%.2X %.2X %.2X ",
-		       hw->mac.addr[0], hw->mac.addr[1],
-		       hw->mac.addr[2]);
-		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-		       hw->mac.addr[4], hw->mac.addr[5]);
+		hw_dbg(hw, " Keeping Current RAR0 Addr =%pM\n", hw->mac.addr);
 	} else {
 		/* Setup the receive address. */
 		hw_dbg(hw, "Overriding MAC Address in RAR[0]\n");
-		hw_dbg(hw, " New MAC Addr =%.2X %.2X %.2X ",
-		       hw->mac.addr[0], hw->mac.addr[1],
-		       hw->mac.addr[2]);
-		hw_dbg(hw, "%.2X %.2X %.2X\n", hw->mac.addr[3],
-		       hw->mac.addr[4], hw->mac.addr[5]);
+		hw_dbg(hw, " New MAC Addr =%pM\n", hw->mac.addr);
 
 		hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
 	} 
