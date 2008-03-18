From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/10] drivers/net/ixgb - Convert u_int8_t to
	u8
Date: Tue, 18 Mar 2008 09:13:50 -0700
Message-ID: <cb3d60ac121b1aa5ecd4908a419115ddd71f749a.1205779120.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
	<1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
	<c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
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
In-Reply-To: <c18867835e6cd98fe94fa418abf7f2432a7786a5.1205779102.git.joe@perches.com>
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
 drivers/net/ixgb/ixgb_ee.c      |    2 +-
 drivers/net/ixgb/ixgb_ee.h      |    6 ++--
 drivers/net/ixgb/ixgb_ethtool.c |   10 ++++----
 drivers/net/ixgb/ixgb_hw.c      |   16 ++++++------
 drivers/net/ixgb/ixgb_hw.h      |   50 +++++++++++++++++++-------------------
 drivers/net/ixgb/ixgb_main.c    |   10 ++++----
 6 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index 8e9302f..a52acbe 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -550,7 +550,7 @@ ixgb_get_eeprom_word(struct ixgb_hw *hw, uint16_t index)
  ******************************************************************************/
 void
 ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
-			uint8_t *mac_addr)
+			u8 *mac_addr)
 {
 	int i;
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
diff --git a/drivers/net/ixgb/ixgb_ee.h b/drivers/net/ixgb/ixgb_ee.h
index da62f58..eaf5efc 100644
--- a/drivers/net/ixgb/ixgb_ee.h
+++ b/drivers/net/ixgb/ixgb_ee.h
@@ -75,7 +75,7 @@
 
 /* EEPROM structure */
 struct ixgb_ee_map_type {
-	uint8_t mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
+	u8 mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];
 	__le16 compatibility;
 	__le16 reserved1[4];
 	__le32 pba_number;
@@ -88,8 +88,8 @@ struct ixgb_ee_map_type {
 	__le16 oem_reserved[16];
 	__le16 swdpins_reg;
 	__le16 circuit_ctrl_reg;
-	uint8_t d3_power;
-	uint8_t d0_power;
+	u8 d3_power;
+	u8 d0_power;
 	__le16 reserved2[28];
 	__le16 checksum;
 };
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 45ddf80..bbf1a4c 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -266,7 +266,7 @@ ixgb_get_regs(struct net_device *netdev,
 	struct ixgb_hw *hw = &adapter->hw;
 	uint32_t *reg = p;
 	uint32_t *reg_start = reg;
-	uint8_t i;
+	u8 i;
 
 	/* the 1 (one) below indicates an attempt at versioning, if the
 	 * interface in ethtool or the driver changes, this 1 should be
@@ -407,7 +407,7 @@ ixgb_get_eeprom_len(struct net_device *netdev)
 
 static int
 ixgb_get_eeprom(struct net_device *netdev,
-		  struct ethtool_eeprom *eeprom, uint8_t *bytes)
+		  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -445,7 +445,7 @@ ixgb_get_eeprom(struct net_device *netdev,
 		eeprom_buff[i] = ixgb_get_eeprom_word(hw, (first_word + i));
 	}
 
-	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
 			eeprom->len);
 	kfree(eeprom_buff);
 
@@ -455,7 +455,7 @@ geeprom_error:
 
 static int
 ixgb_set_eeprom(struct net_device *netdev,
-		  struct ethtool_eeprom *eeprom, uint8_t *bytes)
+		  struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -674,7 +674,7 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 }
 
 static void 
-ixgb_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+ixgb_get_strings(struct net_device *netdev, uint32_t stringset, u8 *data)
 {
 	int i;
 
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 8a04bbd..618a6c6 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -35,7 +35,7 @@
 
 /*  Local function prototypes */
 
-static uint32_t ixgb_hash_mc_addr(struct ixgb_hw *hw, uint8_t * mc_addr);
+static uint32_t ixgb_hash_mc_addr(struct ixgb_hw *hw, u8 * mc_addr);
 
 static void ixgb_mta_set(struct ixgb_hw *hw, uint32_t hash_value);
 
@@ -62,7 +62,7 @@ static uint16_t ixgb_read_phy_reg(struct ixgb_hw *hw,
 
 static bool ixgb_setup_fc(struct ixgb_hw *hw);
 
-static bool mac_addr_valid(uint8_t *mac_addr);
+static bool mac_addr_valid(u8 *mac_addr);
 
 static uint32_t ixgb_mac_reset(struct ixgb_hw *hw)
 {
@@ -437,7 +437,7 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
  *****************************************************************************/
 void
 ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-			  uint8_t *mc_addr_list,
+			  u8 *mc_addr_list,
 			  uint32_t mc_addr_count,
 			  uint32_t pad)
 {
@@ -517,7 +517,7 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
  *****************************************************************************/
 static uint32_t
 ixgb_hash_mc_addr(struct ixgb_hw *hw,
-		   uint8_t *mc_addr)
+		   u8 *mc_addr)
 {
 	uint32_t hash_value = 0;
 
@@ -599,7 +599,7 @@ ixgb_mta_set(struct ixgb_hw *hw,
  *****************************************************************************/
 void
 ixgb_rar_set(struct ixgb_hw *hw,
-		  uint8_t *addr,
+		  u8 *addr,
 		  uint32_t index)
 {
 	uint32_t rar_low, rar_high;
@@ -1155,7 +1155,7 @@ ixgb_get_bus_info(struct ixgb_hw *hw)
  *
  *****************************************************************************/
 static bool
-mac_addr_valid(uint8_t *mac_addr)
+mac_addr_valid(u8 *mac_addr)
 {
 	bool is_valid = true;
 	DEBUGFUNC("mac_addr_valid");
@@ -1193,8 +1193,8 @@ static bool
 ixgb_link_reset(struct ixgb_hw *hw)
 {
 	bool link_status = false;
-	uint8_t wait_retries = MAX_RESET_ITERATIONS;
-	uint8_t lrst_retries = MAX_RESET_ITERATIONS;
+	u8 wait_retries = MAX_RESET_ITERATIONS;
+	u8 lrst_retries = MAX_RESET_ITERATIONS;
 
 	do {
 		/* Reset the link */
diff --git a/drivers/net/ixgb/ixgb_hw.h b/drivers/net/ixgb/ixgb_hw.h
index d4e9566..6fb202f 100644
--- a/drivers/net/ixgb/ixgb_hw.h
+++ b/drivers/net/ixgb/ixgb_hw.h
@@ -538,8 +538,8 @@ struct ixgb_rx_desc {
 	__le64 buff_addr;
 	__le16 length;
 	__le16 reserved;
-	uint8_t status;
-	uint8_t errors;
+	u8 status;
+	u8 errors;
 	__le16 special;
 };
 
@@ -570,8 +570,8 @@ struct ixgb_rx_desc {
 struct ixgb_tx_desc {
 	__le64 buff_addr;
 	__le32 cmd_type_len;
-	uint8_t status;
-	uint8_t popts;
+	u8 status;
+	u8 popts;
 	__le16 vlan;
 };
 
@@ -595,15 +595,15 @@ struct ixgb_tx_desc {
 #define IXGB_TX_DESC_SPECIAL_PRI_SHIFT  IXGB_RX_DESC_SPECIAL_PRI_SHIFT	/* Priority is in upper 3 of 16 */
 
 struct ixgb_context_desc {
-	uint8_t ipcss;
-	uint8_t ipcso;
+	u8 ipcss;
+	u8 ipcso;
 	__le16 ipcse;
-	uint8_t tucss;
-	uint8_t tucso;
+	u8 tucss;
+	u8 tucso;
 	__le16 tucse;
 	__le32 cmd_type_len;
-	uint8_t status;
-	uint8_t hdr_len;
+	u8 status;
+	u8 hdr_len;
 	__le16 mss;
 };
 
@@ -637,26 +637,26 @@ struct ixgb_context_desc {
 
 /* This structure takes a 64k flash and maps it for identification commands */
 struct ixgb_flash_buffer {
-	uint8_t manufacturer_id;
-	uint8_t device_id;
-	uint8_t filler1[0x2AA8];
-	uint8_t cmd2;
-	uint8_t filler2[0x2AAA];
-	uint8_t cmd1;
-	uint8_t filler3[0xAAAA];
+	u8 manufacturer_id;
+	u8 device_id;
+	u8 filler1[0x2AA8];
+	u8 cmd2;
+	u8 filler2[0x2AAA];
+	u8 cmd1;
+	u8 filler3[0xAAAA];
 };
 
 /*
  * This is a little-endian specific check.
  */
 #define IS_MULTICAST(Address) \
-    (bool)(((uint8_t *)(Address))[0] & ((uint8_t)0x01))
+    (bool)(((u8 *)(Address))[0] & ((u8)0x01))
 
 /*
  * Check whether an address is broadcast.
  */
 #define IS_BROADCAST(Address)               \
-    ((((uint8_t *)(Address))[0] == ((uint8_t)0xff)) && (((uint8_t *)(Address))[1] == ((uint8_t)0xff)))
+    ((((u8 *)(Address))[0] == ((u8)0xff)) && (((u8 *)(Address))[1] == ((u8)0xff)))
 
 /* Flow control parameters */
 struct ixgb_fc {
@@ -685,7 +685,7 @@ struct ixgb_bus {
 };
 
 struct ixgb_hw {
-	uint8_t __iomem *hw_addr;/* Base Address of the hardware     */
+	u8 __iomem *hw_addr;/* Base Address of the hardware     */
 	void *back;		/* Pointer to OS-dependent struct   */
 	struct ixgb_fc fc;	/* Flow control parameters          */
 	struct ixgb_bus bus;	/* Bus parameters                   */
@@ -696,7 +696,7 @@ struct ixgb_hw {
 	uint32_t max_frame_size;	/* Maximum frame size supported     */
 	uint32_t mc_filter_type;	/* Multicast filter hash type       */
 	uint32_t num_mc_addrs;	/* Number of current Multicast addrs */
-	uint8_t curr_mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];	/* Individual address currently programmed in MAC */
+	u8 curr_mac_addr[IXGB_ETH_LENGTH_OF_ADDRESS];	/* Individual address currently programmed in MAC */
 	uint32_t num_tx_desc;	/* Number of Transmit descriptors   */
 	uint32_t num_rx_desc;	/* Number of Receive descriptors    */
 	uint32_t rx_buffer_size;	/* Size of Receive buffer           */
@@ -704,7 +704,7 @@ struct ixgb_hw {
 	bool adapter_stopped;	/* State of adapter                 */
 	uint16_t device_id;	/* device id from PCI configuration space */
 	uint16_t vendor_id;	/* vendor id from PCI configuration space */
-	uint8_t revision_id;	/* revision id from PCI configuration space */
+	u8 revision_id;	/* revision id from PCI configuration space */
 	uint16_t subsystem_vendor_id;	/* subsystem vendor id from PCI configuration space */
 	uint16_t subsystem_id;	/* subsystem id from PCI configuration space */
 	uint32_t bar0;		/* Base Address registers           */
@@ -790,13 +790,13 @@ extern void ixgb_check_for_link(struct ixgb_hw *hw);
 extern bool ixgb_check_for_bad_link(struct ixgb_hw *hw);
 
 extern void ixgb_rar_set(struct ixgb_hw *hw,
-				uint8_t *addr,
+				u8 *addr,
 				uint32_t index);
 
 
 /* Filters (multicast, vlan, receive) */
 extern void ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-				   uint8_t *mc_addr_list,
+				   u8 *mc_addr_list,
 				   uint32_t mc_addr_count,
 				   uint32_t pad);
 
@@ -806,7 +806,7 @@ extern void ixgb_write_vfta(struct ixgb_hw *hw,
 				 uint32_t value);
 
 /* Access functions to eeprom data */
-void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, uint8_t *mac_addr);
+void ixgb_get_ee_mac_addr(struct ixgb_hw *hw, u8 *mac_addr);
 uint32_t ixgb_get_ee_pba_number(struct ixgb_hw *hw);
 uint16_t ixgb_get_ee_device_id(struct ixgb_hw *hw);
 bool ixgb_get_eeprom_data(struct ixgb_hw *hw);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c68b182..96374d3 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1099,7 +1099,7 @@ ixgb_set_multi(struct net_device *netdev)
 		rctl |= IXGB_RCTL_MPE;
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 	} else {
-		uint8_t mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
+		u8 mta[IXGB_MAX_NUM_MULTICAST_ADDRESSES *
 			    IXGB_ETH_LENGTH_OF_ADDRESS];
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
@@ -1183,7 +1183,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
 	unsigned int i;
-	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
+	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	uint16_t ipcse, tucse, mss;
 	int err;
 
@@ -1249,7 +1249,7 @@ ixgb_tx_csum(struct ixgb_adapter *adapter, struct sk_buff *skb)
 {
 	struct ixgb_context_desc *context_desc;
 	unsigned int i;
-	uint8_t css, cso;
+	u8 css, cso;
 
 	if(likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		struct ixgb_buffer *buffer_info;
@@ -1373,8 +1373,8 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 	struct ixgb_tx_desc *tx_desc = NULL;
 	struct ixgb_buffer *buffer_info;
 	uint32_t cmd_type_len = adapter->tx_cmd_type;
-	uint8_t status = 0;
-	uint8_t popts = 0;
+	u8 status = 0;
+	u8 popts = 0;
 	unsigned int i;
 
 	if(tx_flags & IXGB_TX_FLAGS_TSO) {
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
