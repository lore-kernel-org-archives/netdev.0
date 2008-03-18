From: Joe Perches <joe@perches.com>
Subject: [PATCH 09/10] drivers/net/ixgb - Convert u_int32_t to
	u32
Date: Tue, 18 Mar 2008 09:13:52 -0700
Message-ID: <45f493409623e31dc2395ecd86d46ada7f077642.1205779120.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
	<1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
	<c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
	<cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
	<ce1830668a3c8a8d63f514ba26dae26dbf71f1f2.1205779120.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <ce1830668a3c8a8d63f514ba26dae26dbf71f1f2.1205779120.git.joe@perches.com>
In-Reply-To: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
References: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
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


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgb/ixgb.h         |   16 +++---
 drivers/net/ixgb/ixgb_ee.c      |   26 +++++-----
 drivers/net/ixgb/ixgb_ethtool.c |   36 ++++++------
 drivers/net/ixgb/ixgb_hw.c      |  110 +++++++++++++++++++-------------------
 drivers/net/ixgb/ixgb_hw.h      |   46 ++++++++--------
 drivers/net/ixgb/ixgb_main.c    |   34 ++++++------
 6 files changed, 134 insertions(+), 134 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index c975564..c1ec56c 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -152,9 +152,9 @@ struct ixgb_desc_ring {
 struct ixgb_adapter {
 	struct timer_list watchdog_timer;
 	struct vlan_group *vlgrp;
-	uint32_t bd_number;
-	uint32_t rx_buffer_len;
-	uint32_t part_num;
+	u32 bd_number;
+	u32 rx_buffer_len;
+	u32 part_num;
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t tx_lock;
@@ -167,11 +167,11 @@ struct ixgb_adapter {
 	struct ixgb_desc_ring tx_ring ____cacheline_aligned_in_smp;
 	unsigned int restart_queue;
 	unsigned long timeo_start;
-	uint32_t tx_cmd_type;
+	u32 tx_cmd_type;
 	uint64_t hw_csum_tx_good;
 	uint64_t hw_csum_tx_error;
-	uint32_t tx_int_delay;
-	uint32_t tx_timeout_count;
+	u32 tx_int_delay;
+	u32 tx_timeout_count;
 	bool tx_int_delay_enable;
 	bool detect_tx_hung;
 
@@ -179,7 +179,7 @@ struct ixgb_adapter {
 	struct ixgb_desc_ring rx_ring;
 	uint64_t hw_csum_rx_error;
 	uint64_t hw_csum_rx_good;
-	uint32_t rx_int_delay;
+	u32 rx_int_delay;
 	bool rx_csum;
 
 	/* OS defined structs */
@@ -192,7 +192,7 @@ struct ixgb_adapter {
 	struct ixgb_hw hw;
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
-	uint32_t alloc_rx_buff_failed;
+	u32 alloc_rx_buff_failed;
 	bool have_msi;
 	unsigned long flags;
 };
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 73403d7..2f7ed52 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -48,7 +48,7 @@ static void ixgb_cleanup_eeprom(struct ixgb_hw *hw);
  *****************************************************************************/
 static void
 ixgb_raise_clock(struct ixgb_hw *hw,
-		  uint32_t *eecd_reg)
+		  u32 *eecd_reg)
 {
 	/* Raise the clock input to the EEPROM (by setting the SK bit), and then
 	 *  wait 50 microseconds.
@@ -67,7 +67,7 @@ ixgb_raise_clock(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_lower_clock(struct ixgb_hw *hw,
-		  uint32_t *eecd_reg)
+		  u32 *eecd_reg)
 {
 	/* Lower the clock input to the EEPROM (by clearing the SK bit), and then
 	 * wait 50 microseconds.
@@ -90,8 +90,8 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 					 u16 data,
 					 u16 count)
 {
-	uint32_t eecd_reg;
-	uint32_t mask;
+	u32 eecd_reg;
+	u32 mask;
 
 	/* We need to shift "count" bits out to the EEPROM. So, value in the
 	 * "data" parameter will be shifted out to the EEPROM one bit at a time.
@@ -136,8 +136,8 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 static u16
 ixgb_shift_in_bits(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
-	uint32_t i;
+	u32 eecd_reg;
+	u32 i;
 	u16 data;
 
 	/* In order to read a register from the EEPROM, we need to shift 16 bits
@@ -179,7 +179,7 @@ ixgb_shift_in_bits(struct ixgb_hw *hw)
 static void
 ixgb_setup_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -201,7 +201,7 @@ ixgb_setup_eeprom(struct ixgb_hw *hw)
 static void
 ixgb_standby_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -235,7 +235,7 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
 static void
 ixgb_clock_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -259,7 +259,7 @@ ixgb_clock_eeprom(struct ixgb_hw *hw)
 static void
 ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
+	u32 eecd_reg;
 
 	eecd_reg = IXGB_READ_REG(hw, EECD);
 
@@ -285,8 +285,8 @@ ixgb_cleanup_eeprom(struct ixgb_hw *hw)
 static bool
 ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 {
-	uint32_t eecd_reg;
-	uint32_t i;
+	u32 eecd_reg;
+	u32 i;
 
 	/* Toggle the CS line.  This in effect tells to EEPROM to actually execute
 	 * the command in question.
@@ -574,7 +574,7 @@ ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
  * Returns:
  *          PBA number if EEPROM contents are valid, 0 otherwise
  ******************************************************************************/
-uint32_t
+u32
 ixgb_get_ee_pba_number(struct ixgb_hw *hw)
 {
 	if (ixgb_check_and_get_eeprom_data(hw) == true)
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 3daf7b9..cfdfa1c 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -185,7 +185,7 @@ ixgb_set_pauseparam(struct net_device *netdev,
 	return 0;
 }
 
-static uint32_t
+static u32
 ixgb_get_rx_csum(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -194,7 +194,7 @@ ixgb_get_rx_csum(struct net_device *netdev)
 }
 
 static int
-ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
+ixgb_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
@@ -209,14 +209,14 @@ ixgb_set_rx_csum(struct net_device *netdev, uint32_t data)
 	return 0;
 }
 	
-static uint32_t
+static u32
 ixgb_get_tx_csum(struct net_device *netdev)
 {
 	return (netdev->features & NETIF_F_HW_CSUM) != 0;
 }
 
 static int
-ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
+ixgb_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	if (data)
 		netdev->features |= NETIF_F_HW_CSUM;
@@ -227,7 +227,7 @@ ixgb_set_tx_csum(struct net_device *netdev, uint32_t data)
 }
 
 static int
-ixgb_set_tso(struct net_device *netdev, uint32_t data)
+ixgb_set_tso(struct net_device *netdev, u32 data)
 {
 	if(data)
 		netdev->features |= NETIF_F_TSO;
@@ -236,7 +236,7 @@ ixgb_set_tso(struct net_device *netdev, uint32_t data)
 	return 0;
 } 
 
-static uint32_t
+static u32
 ixgb_get_msglevel(struct net_device *netdev)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -244,7 +244,7 @@ ixgb_get_msglevel(struct net_device *netdev)
 }
 
 static void
-ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
+ixgb_set_msglevel(struct net_device *netdev, u32 data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	adapter->msg_enable = data;
@@ -254,7 +254,7 @@ ixgb_set_msglevel(struct net_device *netdev, uint32_t data)
 static int 
 ixgb_get_regs_len(struct net_device *netdev)
 {
-#define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
+#define IXGB_REG_DUMP_LEN  136*sizeof(u32)
 	return IXGB_REG_DUMP_LEN;
 }
 
@@ -264,8 +264,8 @@ ixgb_get_regs(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t *reg = p;
-	uint32_t *reg_start = reg;
+	u32 *reg = p;
+	u32 *reg_start = reg;
 	u8 i;
 
 	/* the 1 (one) below indicates an attempt at versioning, if the
@@ -395,7 +395,7 @@ ixgb_get_regs(struct net_device *netdev,
 	*reg++ = IXGB_GET_STAT(adapter, xofftxc);	/* 134 */
 	*reg++ = IXGB_GET_STAT(adapter, rjc);	/* 135 */
 
-	regs->len = (reg - reg_start) * sizeof(uint32_t);
+	regs->len = (reg - reg_start) * sizeof(u32);
 }
 
 static int
@@ -563,12 +563,12 @@ ixgb_set_ringparam(struct net_device *netdev,
 	if(netif_running(adapter->netdev))
 		ixgb_down(adapter, true);
 
-	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
-	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
+	rxdr->count = max(ring->rx_pending,(u32)MIN_RXD);
+	rxdr->count = min(rxdr->count,(u32)MAX_RXD);
 	rxdr->count = ALIGN(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	txdr->count = max(ring->tx_pending,(uint32_t)MIN_TXD);
-	txdr->count = min(txdr->count,(uint32_t)MAX_TXD);
+	txdr->count = max(ring->tx_pending,(u32)MIN_TXD);
+	txdr->count = min(txdr->count,(u32)MAX_TXD);
 	txdr->count = ALIGN(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if(netif_running(adapter->netdev)) {
@@ -624,7 +624,7 @@ ixgb_led_blink_callback(unsigned long data)
 }
 
 static int
-ixgb_phys_id(struct net_device *netdev, uint32_t data)
+ixgb_phys_id(struct net_device *netdev, u32 data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
@@ -669,12 +669,12 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 	for(i = 0; i < IXGB_STATS_LEN; i++) {
 		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
 		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(u32 *)p;
 	}
 }
 
 static void 
-ixgb_get_strings(struct net_device *netdev, uint32_t stringset, u8 *data)
+ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	int i;
 
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 7536eba..04d2003 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -35,9 +35,9 @@
 
 /*  Local function prototypes */
 
-static uint32_t ixgb_hash_mc_addr(struct ixgb_hw *hw, u8 * mc_addr);
+static u32 ixgb_hash_mc_addr(struct ixgb_hw *hw, u8 * mc_addr);
 
-static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value);
+static void ixgb_mta_set(struct ixgb_hw *hw, u32 hash_value);
 
 static void ixgb_get_bus_info(struct ixgb_hw *hw);
 
@@ -56,17 +56,17 @@ static void ixgb_clear_vfta(struct ixgb_hw *hw);
 static void ixgb_init_rx_addrs(struct ixgb_hw *hw);
 
 static u16 ixgb_read_phy_reg(struct ixgb_hw *hw,
-				  uint32_t reg_address,
-				  uint32_t phy_address,
-				  uint32_t device_type);
+				  u32 reg_address,
+				  u32 phy_address,
+				  u32 device_type);
 
 static bool ixgb_setup_fc(struct ixgb_hw *hw);
 
 static bool mac_addr_valid(u8 *mac_addr);
 
-static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
+static u32 ixgb_mac_reset(struct ixgb_hw *hw)
 {
-	uint32_t ctrl_reg;
+	u32 ctrl_reg;
 
 	ctrl_reg =  IXGB_CTRL0_RST |
 				IXGB_CTRL0_SDP3_DIR |   /* All pins are Output=1 */
@@ -117,8 +117,8 @@ static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
 bool
 ixgb_adapter_stop(struct ixgb_hw *hw)
 {
-	uint32_t ctrl_reg;
-	uint32_t icr_reg;
+	u32 ctrl_reg;
+	u32 icr_reg;
 
 	DEBUGFUNC("ixgb_adapter_stop");
 
@@ -179,7 +179,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 static ixgb_xpak_vendor
 ixgb_identify_xpak_vendor(struct ixgb_hw *hw)
 {
-	uint32_t i;
+	u32 i;
 	u16 vendor_name[5];
 	ixgb_xpak_vendor xpak_vendor;
 
@@ -292,8 +292,8 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 bool
 ixgb_init_hw(struct ixgb_hw *hw)
 {
-	uint32_t i;
-	uint32_t ctrl_reg;
+	u32 i;
+	u32 ctrl_reg;
 	bool status;
 
 	DEBUGFUNC("ixgb_init_hw");
@@ -377,7 +377,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 static void
 ixgb_init_rx_addrs(struct ixgb_hw *hw)
 {
-	uint32_t i;
+	u32 i;
 
 	DEBUGFUNC("ixgb_init_rx_addrs");
 
@@ -438,12 +438,12 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
 void
 ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 			  u8 *mc_addr_list,
-			  uint32_t mc_addr_count,
-			  uint32_t pad)
+			  u32 mc_addr_count,
+			  u32 pad)
 {
-	uint32_t hash_value;
-	uint32_t i;
-	uint32_t rar_used_count = 1;		/* RAR[0] is used for our MAC address */
+	u32 hash_value;
+	u32 i;
+	u32 rar_used_count = 1;		/* RAR[0] is used for our MAC address */
 
 	DEBUGFUNC("ixgb_mc_addr_list_update");
 
@@ -515,11 +515,11 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
  * Returns:
  *      The hash value
  *****************************************************************************/
-static uint32_t
+static u32
 ixgb_hash_mc_addr(struct ixgb_hw *hw,
 		   u8 *mc_addr)
 {
-	uint32_t hash_value = 0;
+	u32 hash_value = 0;
 
 	DEBUGFUNC("ixgb_hash_mc_addr");
 
@@ -565,10 +565,10 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_mta_set(struct ixgb_hw *hw,
-		  uint32_t hash_value)
+		  u32 hash_value)
 {
-	uint32_t hash_bit, hash_reg;
-	uint32_t mta_reg;
+	u32 hash_bit, hash_reg;
+	u32 mta_reg;
 
 	/* The MTA is a register array of 128 32-bit registers.
 	 * It is treated like an array of 4096 bits.  We want to set
@@ -600,22 +600,22 @@ ixgb_mta_set(struct ixgb_hw *hw,
 void
 ixgb_rar_set(struct ixgb_hw *hw,
 		  u8 *addr,
-		  uint32_t index)
+		  u32 index)
 {
-	uint32_t rar_low, rar_high;
+	u32 rar_low, rar_high;
 
 	DEBUGFUNC("ixgb_rar_set");
 
 	/* HW expects these in little endian so we reverse the byte order
 	 * from network order (big endian) to little endian
 	 */
-	rar_low = ((uint32_t) addr[0] |
-		   ((uint32_t)addr[1] << 8) |
-		   ((uint32_t)addr[2] << 16) |
-		   ((uint32_t)addr[3] << 24));
+	rar_low = ((u32) addr[0] |
+		   ((u32)addr[1] << 8) |
+		   ((u32)addr[2] << 16) |
+		   ((u32)addr[3] << 24));
 
-	rar_high = ((uint32_t) addr[4] |
-			((uint32_t)addr[5] << 8) |
+	rar_high = ((u32) addr[4] |
+			((u32)addr[5] << 8) |
 			IXGB_RAH_AV);
 
 	IXGB_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
@@ -632,8 +632,8 @@ ixgb_rar_set(struct ixgb_hw *hw,
  *****************************************************************************/
 void
 ixgb_write_vfta(struct ixgb_hw *hw,
-		 uint32_t offset,
-		 uint32_t value)
+		 u32 offset,
+		 u32 value)
 {
 	IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, value);
 	return;
@@ -647,7 +647,7 @@ ixgb_write_vfta(struct ixgb_hw *hw,
 static void
 ixgb_clear_vfta(struct ixgb_hw *hw)
 {
-	uint32_t offset;
+	u32 offset;
 
 	for(offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
@@ -663,8 +663,8 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
 static bool
 ixgb_setup_fc(struct ixgb_hw *hw)
 {
-	uint32_t ctrl_reg;
-	uint32_t pap_reg = 0;   /* by default, assume no pause time */
+	u32 ctrl_reg;
+	u32 pap_reg = 0;   /* by default, assume no pause time */
 	bool status = true;
 
 	DEBUGFUNC("ixgb_setup_fc");
@@ -764,13 +764,13 @@ ixgb_setup_fc(struct ixgb_hw *hw)
  *****************************************************************************/
 static u16
 ixgb_read_phy_reg(struct ixgb_hw *hw,
-		uint32_t reg_address,
-		uint32_t phy_address,
-		uint32_t device_type)
+		u32 reg_address,
+		u32 phy_address,
+		u32 device_type)
 {
-	uint32_t i;
-	uint32_t data;
-	uint32_t command = 0;
+	u32 i;
+	u32 data;
+	u32 command = 0;
 
 	ASSERT(reg_address <= IXGB_MAX_PHY_REG_ADDRESS);
 	ASSERT(phy_address <= IXGB_MAX_PHY_ADDRESS);
@@ -857,20 +857,20 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
  *****************************************************************************/
 static void
 ixgb_write_phy_reg(struct ixgb_hw *hw,
-			uint32_t reg_address,
-			uint32_t phy_address,
-			uint32_t device_type,
+			u32 reg_address,
+			u32 phy_address,
+			u32 device_type,
 			u16 data)
 {
-	uint32_t i;
-	uint32_t command = 0;
+	u32 i;
+	u32 command = 0;
 
 	ASSERT(reg_address <= IXGB_MAX_PHY_REG_ADDRESS);
 	ASSERT(phy_address <= IXGB_MAX_PHY_ADDRESS);
 	ASSERT(device_type <= IXGB_MAX_PHY_DEV_TYPE);
 
 	/* Put the data in the MDIO Read/Write Data register */
-	IXGB_WRITE_REG(hw, MSRWD, (uint32_t)data);
+	IXGB_WRITE_REG(hw, MSRWD, (u32)data);
 
 	/* Setup and write the address cycle command */
 	command = ((reg_address << IXGB_MSCA_NP_ADDR_SHIFT)  |
@@ -939,8 +939,8 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 void
 ixgb_check_for_link(struct ixgb_hw *hw)
 {
-	uint32_t status_reg;
-	uint32_t xpcss_reg;
+	u32 status_reg;
+	u32 xpcss_reg;
 
 	DEBUGFUNC("ixgb_check_for_link");
 
@@ -975,7 +975,7 @@ ixgb_check_for_link(struct ixgb_hw *hw)
  *****************************************************************************/
 bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 {
-	uint32_t newLFC, newRFC;
+	u32 newLFC, newRFC;
 	bool bad_link_returncode = false;
 
 	if (hw->phy_type == ixgb_phy_type_txn17401) {
@@ -1002,7 +1002,7 @@ bool ixgb_check_for_bad_link(struct ixgb_hw *hw)
 static void
 ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 {
-	volatile uint32_t temp_reg;
+	volatile u32 temp_reg;
 
 	DEBUGFUNC("ixgb_clear_hw_cntrs");
 
@@ -1083,7 +1083,7 @@ ixgb_clear_hw_cntrs(struct ixgb_hw *hw)
 void
 ixgb_led_on(struct ixgb_hw *hw)
 {
-	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
+	u32 ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
 	/* To turn on the LED, clear software-definable pin 0 (SDP0). */
 	ctrl0_reg &= ~IXGB_CTRL0_SDP0;
@@ -1099,7 +1099,7 @@ ixgb_led_on(struct ixgb_hw *hw)
 void
 ixgb_led_off(struct ixgb_hw *hw)
 {
-	uint32_t ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
+	u32 ctrl0_reg = IXGB_READ_REG(hw, CTRL0);
 
 	/* To turn off the LED, set software-definable pin 0 (SDP0). */
 	ctrl0_reg |= IXGB_CTRL0_SDP0;
@@ -1115,7 +1115,7 @@ ixgb_led_off(struct ixgb_hw *hw)
 static void
 ixgb_get_bus_info(struct ixgb_hw *hw)
 {
-	uint32_t status_reg;
+	u32 status_reg;
 
 	status_reg = IXGB_READ_REG(hw, STATUS);
 
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index a4dc8df..f31cba0 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -660,8 +660,8 @@ struct ixgb_flash_buffer {
 
 /* Flow control parameters */
 struct ixgb_fc {
-	uint32_t high_water;	/* Flow Control High-water          */
-	uint32_t low_water;	/* Flow Control Low-water           */
+	u32 high_water;	/* Flow Control High-water          */
+	u32 low_water;	/* Flow Control Low-water           */
 	u16 pause_time;	/* Flow Control Pause timer         */
 	bool send_xon;		/* Flow control send XON            */
 	ixgb_fc_type type;	/* Type of flow control             */
@@ -689,17 +689,17 @@ struct ixgb_hw {
 	void *back;		/* Pointer to OS-dependent struct   */
 	struct ixgb_fc fc;	/* Flow control parameters          */
 	struct ixgb_bus bus;	/* Bus parameters                   */
-	uint32_t phy_id;	/* Phy Identifier                   */
-	uint32_t phy_addr;	/* XGMII address of Phy             */
+	u32 phy_id;	/* Phy Identifier                   */
+	u32 phy_addr;	/* XGMII address of Phy             */
 	ixgb_mac_type mac_type;	/* Identifier for MAC controller    */
 	ixgb_phy_type phy_type;	/* Transceiver/phy identifier       */
-	uint32_t max_frame_size;	/* Maximum frame size supported     */
-	uint32_t mc_filter_type;	/* Multicast filter hash type       */
-	uint32_t num_mc_addrs;	/* Number of current Multicast addrs */
+	u32 max_frame_size;	/* Maximum frame size supported     */
+	u32 mc_filter_type;	/* Multicast filter hash type       */
+	u32 num_mc_addrs;	/* Number of current Multicast addrs */
 	u8 curr_mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];	/* Individual address currently programmed in MAC */
-	uint32_t num_tx_desc;	/* Number of Transmit descriptors   */
-	uint32_t num_rx_desc;	/* Number of Receive descriptors    */
-	uint32_t rx_buffer_size;	/* Size of Receive buffer           */
+	u32 num_tx_desc;	/* Number of Transmit descriptors   */
+	u32 num_rx_desc;	/* Number of Receive descriptors    */
+	u32 rx_buffer_size;	/* Size of Receive buffer           */
 	bool link_up;		/* true if link is valid            */
 	bool adapter_stopped;	/* State of adapter                 */
 	u16 device_id;	/* device id from PCI configuration space */
@@ -707,15 +707,15 @@ struct ixgb_hw {
 	u8 revision_id;	/* revision id from PCI configuration space */
 	u16 subsystem_vendor_id;	/* subsystem vendor id from PCI configuration space */
 	u16 subsystem_id;	/* subsystem id from PCI configuration space */
-	uint32_t bar0;		/* Base Address registers           */
-	uint32_t bar1;
-	uint32_t bar2;
-	uint32_t bar3;
+	u32 bar0;		/* Base Address registers           */
+	u32 bar1;
+	u32 bar2;
+	u32 bar3;
 	u16 pci_cmd_word;	/* PCI command register id from PCI configuration space */
 	__le16 eeprom[IXGB_EEPROM_SIZE];	/* EEPROM contents read at init time  */
 	unsigned long io_base;	/* Our I/O mapped location */
-	uint32_t lastLFC;
-	uint32_t lastRFC;
+	u32 lastLFC;
+	u32 lastRFC;
 };
 
 /* Statistics reported by the hardware */
@@ -791,23 +791,23 @@ extern bool ixgb_check_for_bad_link(struct ixgb_hw *hw);
 
 extern void ixgb_rar_set(struct ixgb_hw *hw,
 				u8 *addr,
-				uint32_t index);
+				u32 index);
 
 
 /* Filters (multicast, vlan, receive) */
 extern void ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 				   u8 *mc_addr_list,
-				   uint32_t mc_addr_count,
-				   uint32_t pad);
+				   u32 mc_addr_count,
+				   u32 pad);
 
 /* Vfta functions */
 extern void ixgb_write_vfta(struct ixgb_hw *hw,
-				 uint32_t offset,
-				 uint32_t value);
+				 u32 offset,
+				 u32 value);
 
 /* Access functions to eeprom data */
 void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, u8 *mac_addr);
-uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
+u32 ixgb_get_ee_pba_number(struct ixgb_hw *hw);
 u16 ixgb_get_ee_device_id(struct ixgb_hw *hw);
 bool ixgb_get_eeprom_data(struct ixgb_hw *hw);
 __le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index);
@@ -816,7 +816,7 @@ __le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index);
 void ixgb_led_on(struct ixgb_hw *hw);
 void ixgb_led_off(struct ixgb_hw *hw);
 void ixgb_write_pci_cfg(struct ixgb_hw *hw,
-			 uint32_t reg,
+			 u32 reg,
 			 u16 * value);
 
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index e5032be..e99b855 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -271,7 +271,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 		if(hw->max_frame_size >
 		   IXGB_MAX_ENET_FRAME_SIZE_WITHOUT_FCS + ENET_FCS_LENGTH) {
-			uint32_t ctrl0 = IXGB_READ_REG(hw, CTRL0);
+			u32 ctrl0 = IXGB_READ_REG(hw, CTRL0);
 
 			if(!(ctrl0 & IXGB_CTRL0_JFE)) {
 				ctrl0 |= IXGB_CTRL0_JFE;
@@ -719,8 +719,8 @@ static void
 ixgb_configure_tx(struct ixgb_adapter *adapter)
 {
 	uint64_t tdba = adapter->tx_ring.dma;
-	uint32_t tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
-	uint32_t tctl;
+	u32 tdlen = adapter->tx_ring.count * sizeof(struct ixgb_tx_desc);
+	u32 tctl;
 	struct ixgb_hw *hw = &adapter->hw;
 
 	/* Setup the Base and Length of the Tx Descriptor Ring 
@@ -806,7 +806,7 @@ ixgb_setup_rx_resources(struct ixgb_adapter *adapter)
 static void
 ixgb_setup_rctl(struct ixgb_adapter *adapter)
 {
-	uint32_t rctl;
+	u32 rctl;
 
 	rctl = IXGB_READ_REG(&adapter->hw, RCTL);
 
@@ -842,11 +842,11 @@ static void
 ixgb_configure_rx(struct ixgb_adapter *adapter)
 {
 	uint64_t rdba = adapter->rx_ring.dma;
-	uint32_t rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
+	u32 rdlen = adapter->rx_ring.count * sizeof(struct ixgb_rx_desc);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t rctl;
-	uint32_t rxcsum;
-	uint32_t rxdctl;
+	u32 rctl;
+	u32 rxcsum;
+	u32 rxdctl;
 
 	/* make sure receives are disabled while setting up the descriptors */
 
@@ -1079,7 +1079,7 @@ ixgb_set_multi(struct net_device *netdev)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
 	struct dev_mc_list *mc_ptr;
-	uint32_t rctl;
+	u32 rctl;
 	int i;
 
 	/* Check for Promiscuous and All Multicast modes */
@@ -1265,7 +1265,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 		context_desc->tucso = cso;
 		context_desc->tucse = 0;
 		/* zero out any previously existing data in one instruction */
-		*(uint32_t *)&(context_desc->ipcss) = 0;
+		*(u32 *)&(context_desc->ipcss) = 0;
 		context_desc->status = 0;
 		context_desc->hdr_len = 0;
 		context_desc->mss = 0;
@@ -1372,7 +1372,7 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 	struct ixgb_desc_ring *tx_ring = &adapter->tx_ring;
 	struct ixgb_tx_desc *tx_desc = NULL;
 	struct ixgb_buffer *buffer_info;
-	uint32_t cmd_type_len = adapter->tx_cmd_type;
+	u32 cmd_type_len = adapter->tx_cmd_type;
 	u8 status = 0;
 	u8 popts = 0;
 	unsigned int i;
@@ -1750,7 +1750,7 @@ ixgb_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	uint32_t icr = IXGB_READ_REG(hw, ICR);
+	u32 icr = IXGB_READ_REG(hw, ICR);
 #ifndef CONFIG_IXGB_NAPI
 	unsigned int i;
 #endif
@@ -1843,7 +1843,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 			ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 
-			*(uint32_t *)&(tx_desc->status) = 0;
+			*(u32 *)&(tx_desc->status) = 0;
 
 			cleaned = (i == eop);
 			if(++i == tx_ring->count) i = 0;
@@ -1948,7 +1948,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	struct ixgb_rx_desc *rx_desc, *next_rxd;
 	struct ixgb_buffer *buffer_info, *next_buffer, *next2_buffer;
-	uint32_t length;
+	u32 length;
 	unsigned int i, j;
 	bool cleaned = false;
 
@@ -2166,7 +2166,7 @@ static void
 ixgb_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, rctl;
+	u32 ctrl, rctl;
 
 	ixgb_irq_disable(adapter);
 	adapter->vlgrp = grp;
@@ -2206,7 +2206,7 @@ static void
 ixgb_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	/* add VID to filter table */
 
@@ -2220,7 +2220,7 @@ static void
 ixgb_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	ixgb_irq_disable(adapter);
 
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
