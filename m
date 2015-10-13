From: Janusz Wolak <januszwolak@awokados.com.pl>
Subject: [PATCH 4/6] e1000 driver remove checkpatch errors, warnings and checks.
Date: Tue, 13 Oct 2015 23:39:20 +0200
Message-ID: <1444772362-25090-4-git-send-email-januszwolak@awokados.com.pl>
References: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Cc: jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	matthew.vick@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Janusz Wolak <januszvdm@gmail.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444772362-25090-1-git-send-email-januszwolak@awokados.com.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Janusz Wolak <januszvdm@gmail.com>

Signed-off-by: Janusz Wolak <januszvdm@gmail.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.h | 154 +++++++++++++++-------------
 1 file changed, 80 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.h b/drivers/net/ethernet/intel/e1000/e1000_hw.h
index 5cf7268c..65a9640 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.h
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.h
@@ -1,5 +1,5 @@
 /*******************************************************************************
-
+*
   Intel PRO/1000 Linux driver
   Copyright(c) 1999 - 2006 Intel Corporation.
 
@@ -285,7 +285,7 @@ typedef enum {
 #define E1000_BLK_PHY_RESET   12
 
 #define E1000_BYTE_SWAP_WORD(_value) ((((_value) & 0x00ff) << 8) | \
-                                     (((_value) & 0xff00) >> 8))
+				     (((_value) & 0xff00) >> 8))
 
 /* Function prototypes */
 /* Initialization */
@@ -299,11 +299,11 @@ s32 e1000_setup_link(struct e1000_hw *hw);
 s32 e1000_phy_setup_autoneg(struct e1000_hw *hw);
 void e1000_config_collision_dist(struct e1000_hw *hw);
 s32 e1000_check_for_link(struct e1000_hw *hw);
-s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 * speed, u16 * duplex);
+s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex);
 s32 e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
-s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 * phy_data);
+s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data);
 s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
 s32 e1000_phy_hw_reset(struct e1000_hw *hw);
 s32 e1000_phy_reset(struct e1000_hw *hw);
@@ -344,6 +344,7 @@ struct e1000_host_mng_command_info {
 	struct e1000_host_mng_command_header command_header;	/* Command Head/Command Result Head has 4 bytes */
 	u8 command_data[E1000_HI_MAX_MNG_DATA_LENGTH];	/* Command data can length 0..0x658 */
 };
+
 #ifdef __BIG_ENDIAN
 struct e1000_host_mng_dhcp_cookie {
 	u32 signature;
@@ -369,16 +370,16 @@ struct e1000_host_mng_dhcp_cookie {
 #endif
 
 bool e1000_check_mng_mode(struct e1000_hw *hw);
-s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 * data);
+s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
 s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw);
 s32 e1000_update_eeprom_checksum(struct e1000_hw *hw);
-s32 e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 * data);
+s32 e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
 s32 e1000_read_mac_addr(struct e1000_hw *hw);
 
 /* Filters (multicast, vlan, receive) */
-u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
+u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 *mc_addr);
 void e1000_mta_set(struct e1000_hw *hw, u32 hash_value);
-void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, u32 rar_index);
+void e1000_rar_set(struct e1000_hw *hw, u8 *mc_addr, u32 rar_index);
 void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
 
 /* LED functions */
@@ -401,10 +402,8 @@ int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
 void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
 
-#define E1000_READ_REG_IO(a, reg) \
-    e1000_read_reg_io((a), E1000_##reg)
-#define E1000_WRITE_REG_IO(a, reg, val) \
-    e1000_write_reg_io((a), E1000_##reg, val)
+#define E1000_READ_REG_IO(a, reg) e1000_read_reg_io((a), E1000_##reg)
+#define E1000_WRITE_REG_IO(a, reg, val) e1000_write_reg_io((a), E1000_##reg, val)
 
 /* PCI Device IDs */
 #define E1000_DEV_ID_82542               0x1000
@@ -467,8 +466,7 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
 #define ENET_HEADER_SIZE             14
 #define MINIMUM_ETHERNET_FRAME_SIZE  64	/* With FCS */
 #define ETHERNET_FCS_SIZE            4
-#define MINIMUM_ETHERNET_PACKET_SIZE \
-    (MINIMUM_ETHERNET_FRAME_SIZE - ETHERNET_FCS_SIZE)
+#define MINIMUM_ETHERNET_PACKET_SIZE (MINIMUM_ETHERNET_FRAME_SIZE - ETHERNET_FCS_SIZE)
 #define CRC_LENGTH                   ETHERNET_FCS_SIZE
 #define MAX_JUMBO_FRAME_SIZE         0x3F00
 
@@ -489,9 +487,7 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
  *   o RXDMT0 = Receive Descriptor Minimum Threshold hit (ring 0)
  *   o RXSEQ  = Receive Sequence Error
  */
-#define POLL_IMS_ENABLE_MASK ( \
-    E1000_IMS_RXDMT0 |         \
-    E1000_IMS_RXSEQ)
+#define POLL_IMS_ENABLE_MASK (E1000_IMS_RXDMT0 | E1000_IMS_RXSEQ)
 
 /* This defines the bits that are set in the Interrupt Mask
  * Set/Read Register.  Each bit is documented below:
@@ -501,12 +497,8 @@ void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
  *   o RXSEQ  = Receive Sequence Error
  *   o LSC    = Link Status Change
  */
-#define IMS_ENABLE_MASK ( \
-    E1000_IMS_RXT0   |    \
-    E1000_IMS_TXDW   |    \
-    E1000_IMS_RXDMT0 |    \
-    E1000_IMS_RXSEQ  |    \
-    E1000_IMS_LSC)
+#define IMS_ENABLE_MASK (E1000_IMS_RXT0 | E1000_IMS_TXDW | E1000_IMS_RXDMT0 | \
+			 E1000_IMS_RXSEQ | E1000_IMS_LSC)
 
 /* Number of high/low register pairs in the RAR. The RAR (Receive Address
  * Registers) holds the directed and multicast addresses that we monitor. We
@@ -621,20 +613,16 @@ union e1000_rx_desc_packet_split {
 #define E1000_RXDPS_HDRSTAT_HDRLEN_MASK  0x000003FF
 
 /* mask to determine if packets should be dropped due to frame errors */
-#define E1000_RXD_ERR_FRAME_ERR_MASK ( \
-    E1000_RXD_ERR_CE  |                \
-    E1000_RXD_ERR_SE  |                \
-    E1000_RXD_ERR_SEQ |                \
-    E1000_RXD_ERR_CXE |                \
-    E1000_RXD_ERR_RXE)
+#define E1000_RXD_ERR_FRAME_ERR_MASK (E1000_RXD_ERR_CE | E1000_RXD_ERR_SE | \
+				      E1000_RXD_ERR_SEQ | E1000_RXD_ERR_CXE | \
+				      E1000_RXD_ERR_RXE)
 
 /* Same mask, but for extended and packet split descriptors */
-#define E1000_RXDEXT_ERR_FRAME_ERR_MASK ( \
-    E1000_RXDEXT_STATERR_CE  |            \
-    E1000_RXDEXT_STATERR_SE  |            \
-    E1000_RXDEXT_STATERR_SEQ |            \
-    E1000_RXDEXT_STATERR_CXE |            \
-    E1000_RXDEXT_STATERR_RXE)
+#define E1000_RXDEXT_ERR_FRAME_ERR_MASK (E1000_RXDEXT_STATERR_CE | \
+					 E1000_RXDEXT_STATERR_SE | \
+					 E1000_RXDEXT_STATERR_SEQ | \
+					 E1000_RXDEXT_STATERR_CXE | \
+					 E1000_RXDEXT_STATERR_RXE)
 
 /* Transmit Descriptor */
 struct e1000_tx_desc {
@@ -1094,7 +1082,8 @@ struct e1000_ffvt_entry {
 #define E1000_82542_RDH0     E1000_82542_RDH
 #define E1000_82542_RDT0     E1000_82542_RDT
 #define E1000_82542_SRRCTL(_n) (0x280C + ((_n) << 8))	/* Split and Replication
-							 * RX Control - RW */
+							 * RX Control - RW
+							 */
 #define E1000_82542_DCA_RXCTRL(_n) (0x02814 + ((_n) << 8))
 #define E1000_82542_RDBAH3   0x02B04	/* RX Desc Base High Queue 3 - RW */
 #define E1000_82542_RDBAL3   0x02B00	/* RX Desc Low Queue 3 - RW */
@@ -1494,7 +1483,8 @@ struct e1000_hw {
 #define E1000_STATUS_SPEED_100  0x00000040	/* Speed 100Mb/s */
 #define E1000_STATUS_SPEED_1000 0x00000080	/* Speed 1000Mb/s */
 #define E1000_STATUS_LAN_INIT_DONE 0x00000200	/* Lan Init Completion
-						   by EEPROM/Flash */
+						 * by EEPROM/Flash
+						 */
 #define E1000_STATUS_ASDV       0x00000300	/* Auto speed detect value */
 #define E1000_STATUS_DOCK_CI    0x00000800	/* Change in Dock/Undock state. Clear on write '0'. */
 #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000	/* Status of Master requests. */
@@ -1533,7 +1523,8 @@ struct e1000_hw {
 #define E1000_EECD_PRES      0x00000100	/* EEPROM Present */
 #define E1000_EECD_SIZE      0x00000200	/* EEPROM Size (0=64 word 1=256 word) */
 #define E1000_EECD_ADDR_BITS 0x00000400	/* EEPROM Addressing bits based on type
-					 * (0-small, 1-large) */
+					 * (0-small, 1-large)
+					 */
 #define E1000_EECD_TYPE      0x00002000	/* EEPROM Type (1-SPI, 0-Microwire) */
 #ifndef E1000_EEPROM_GRANT_ATTEMPTS
 #define E1000_EEPROM_GRANT_ATTEMPTS 1000	/* EEPROM # attempts to gain grant */
@@ -1949,7 +1940,8 @@ struct e1000_hw {
 #define E1000_TXDCTL_LWTHRESH 0xFE000000	/* TXDCTL Low Threshold */
 #define E1000_TXDCTL_FULL_TX_DESC_WB 0x01010000	/* GRAN=1, WTHRESH=1 */
 #define E1000_TXDCTL_COUNT_DESC 0x00400000	/* Enable the counting of desc.
-						   still to be processed. */
+						 * still to be processed.
+						 */
 /* Transmit Configuration Word */
 #define E1000_TXCW_FD         0x00000020	/* TXCW full duplex */
 #define E1000_TXCW_HD         0x00000040	/* TXCW half duplex */
@@ -2059,7 +2051,8 @@ struct e1000_hw {
 #define E1000_MANC_SNAP_EN       0x00001000	/* Accept LLC/SNAP */
 #define E1000_MANC_ARP_EN        0x00002000	/* Enable ARP Request Filtering */
 #define E1000_MANC_NEIGHBOR_EN   0x00004000	/* Enable Neighbor Discovery
-						 * Filtering */
+						 * Filtering
+						 */
 #define E1000_MANC_ARP_RES_EN    0x00008000	/* Enable ARP response Filtering */
 #define E1000_MANC_TCO_RESET     0x00010000	/* TCO Reset Occurred */
 #define E1000_MANC_RCV_TCO_EN    0x00020000	/* Receive TCO Packets Enabled */
@@ -2067,11 +2060,14 @@ struct e1000_hw {
 #define E1000_MANC_RCV_ALL       0x00080000	/* Receive All Enabled */
 #define E1000_MANC_BLK_PHY_RST_ON_IDE   0x00040000	/* Block phy resets */
 #define E1000_MANC_EN_MAC_ADDR_FILTER   0x00100000	/* Enable MAC address
-							 * filtering */
+							 * filtering
+							 */
 #define E1000_MANC_EN_MNG2HOST   0x00200000	/* Enable MNG packets to host
-						 * memory */
+						 * memory
+						 */
 #define E1000_MANC_EN_IP_ADDR_FILTER    0x00400000	/* Enable IP address
-							 * filtering */
+							 * filtering
+							 */
 #define E1000_MANC_EN_XSUM_FILTER   0x00800000	/* Enable checksum filtering */
 #define E1000_MANC_BR_EN         0x01000000	/* Enable broadcast filtering */
 #define E1000_MANC_SMB_REQ       0x01000000	/* SMBus Request */
@@ -2118,7 +2114,8 @@ typedef enum {
 /* Host Interface Control Register */
 #define E1000_HICR_EN           0x00000001	/* Enable Bit - RO */
 #define E1000_HICR_C            0x00000002	/* Driver sets this bit when done
-						 * to put command in RAM */
+						 * to put command in RAM
+						 */
 #define E1000_HICR_SV           0x00000004	/* Status Validity */
 #define E1000_HICR_FWR          0x00000080	/* FW reset. Set by the Host */
 
@@ -2134,6 +2131,7 @@ struct e1000_host_command_header {
 	u8 command_options;	/* I/F bits for command, status for return */
 	u8 checksum;
 };
+
 struct e1000_host_command_info {
 	struct e1000_host_command_header command_header;	/* Command Head/Command Result Head has 4 bytes */
 	u8 command_data[E1000_HI_MAX_DATA_LENGTH];	/* Command data can length 0..252 */
@@ -2170,11 +2168,11 @@ struct e1000_host_command_info {
 #define E1000_GCR_TXDSCR_NO_SNOOP       0x00000020
 
 #define PCI_EX_NO_SNOOP_ALL (E1000_GCR_RXD_NO_SNOOP         | \
-                             E1000_GCR_RXDSCW_NO_SNOOP      | \
-                             E1000_GCR_RXDSCR_NO_SNOOP      | \
-                             E1000_GCR_TXD_NO_SNOOP         | \
-                             E1000_GCR_TXDSCW_NO_SNOOP      | \
-                             E1000_GCR_TXDSCR_NO_SNOOP)
+			     E1000_GCR_RXDSCW_NO_SNOOP      | \
+			     E1000_GCR_RXDSCR_NO_SNOOP      | \
+			     E1000_GCR_TXD_NO_SNOOP         | \
+			     E1000_GCR_TXDSCW_NO_SNOOP      | \
+			     E1000_GCR_TXDSCR_NO_SNOOP)
 
 #define PCI_EX_82566_SNOOP_ALL PCI_EX_NO_SNOOP_ALL
 
@@ -2257,9 +2255,9 @@ struct e1000_host_command_info {
 #define ID_LED_RESERVED_0000 0x0000
 #define ID_LED_RESERVED_FFFF 0xFFFF
 #define ID_LED_DEFAULT       ((ID_LED_OFF1_ON2 << 12) | \
-                              (ID_LED_OFF1_OFF2 << 8) | \
-                              (ID_LED_DEF1_DEF2 << 4) | \
-                              (ID_LED_DEF1_DEF2))
+			      (ID_LED_OFF1_OFF2 << 8) | \
+			      (ID_LED_DEF1_DEF2 << 4) | \
+			      (ID_LED_DEF1_DEF2))
 #define ID_LED_DEF1_DEF2     0x1
 #define ID_LED_DEF1_ON2      0x2
 #define ID_LED_DEF1_OFF2     0x3
@@ -2318,7 +2316,8 @@ struct e1000_host_command_info {
 #define E1000_COLLISION_THRESHOLD       15
 #define E1000_CT_SHIFT                  4
 /* Collision distance is a 0-based value that applies to
- * half-duplex-capable hardware only. */
+ * half-duplex-capable hardware only.
+ */
 #define E1000_COLLISION_DISTANCE        63
 #define E1000_COLLISION_DISTANCE_82542  64
 #define E1000_FDX_COLLISION_DISTANCE    E1000_COLLISION_DISTANCE
@@ -2482,10 +2481,10 @@ struct e1000_host_command_info {
      (((errors) & E1000_RXD_ERR_FRAME_ERR_MASK) == E1000_RXD_ERR_CE) && \
      ((last_byte) == CARRIER_EXTENSION) && \
      (((status) & E1000_RXD_STAT_VP) ? \
-          (((length) > ((adapter)->min_frame_size - VLAN_TAG_SIZE)) && \
-           ((length) <= ((adapter)->max_frame_size + 1))) : \
-          (((length) > (adapter)->min_frame_size) && \
-           ((length) <= ((adapter)->max_frame_size + VLAN_TAG_SIZE + 1)))))
+	  (((length) > ((adapter)->min_frame_size - VLAN_TAG_SIZE)) && \
+	   ((length) <= ((adapter)->max_frame_size + 1))) : \
+	  (((length) > (adapter)->min_frame_size) && \
+	   ((length) <= ((adapter)->max_frame_size + VLAN_TAG_SIZE + 1)))))
 
 /* Structures, enums, and macros for the PHY */
 
@@ -2582,7 +2581,8 @@ struct e1000_host_command_info {
 
 #define IGP01E1000_PHY_DSP_FFE_DEFAULT      0x002A
 /* IGP01E1000 PCS Initialization register - stores the polarity status when
- * speed = 1000 Mbps. */
+ * speed = 1000 Mbps.
+ */
 #define IGP01E1000_PHY_PCS_INIT_REG  0x00B4
 #define IGP01E1000_PHY_PCS_CTRL_REG  0x00B5
 
@@ -2739,10 +2739,12 @@ struct e1000_host_command_info {
 #define M88E1000_PSCR_10BT_EXT_DIST_ENABLE 0x0080
 					/* 1=Enable Extended 10BASE-T distance
 					 * (Lower 10BASE-T RX Threshold)
-					 * 0=Normal 10BASE-T RX Threshold */
+					 * 0=Normal 10BASE-T RX Threshold
+					 */
 #define M88E1000_PSCR_MII_5BIT_ENABLE      0x0100
 					/* 1=5-Bit interface in 100BASE-TX
-					 * 0=MII interface in 100BASE-TX */
+					 * 0=MII interface in 100BASE-TX
+					 */
 #define M88E1000_PSCR_SCRAMBLER_DISABLE    0x0200	/* 1=Scrambler disable */
 #define M88E1000_PSCR_FORCE_LINK_GOOD      0x0400	/* 1=Force link good */
 #define M88E1000_PSCR_ASSERT_CRS_ON_TX     0x0800	/* 1=Assert CRS on Transmit */
@@ -2757,7 +2759,8 @@ struct e1000_host_command_info {
 #define M88E1000_PSSR_DOWNSHIFT          0x0020	/* 1=Downshifted */
 #define M88E1000_PSSR_MDIX               0x0040	/* 1=MDIX; 0=MDI */
 #define M88E1000_PSSR_CABLE_LENGTH       0x0380	/* 0=<50M;1=50-80M;2=80-110M;
-						 * 3=110-140M;4=>140M */
+						 * 3=110-140M;4=>140M
+						 */
 #define M88E1000_PSSR_LINK               0x0400	/* 1=Link up, 0=Link down */
 #define M88E1000_PSSR_SPD_DPLX_RESOLVED  0x0800	/* 1=Speed & Duplex resolved */
 #define M88E1000_PSSR_PAGE_RCVD          0x1000	/* 1=Page received */
@@ -2780,14 +2783,16 @@ struct e1000_host_command_info {
 						 * within 1ms in 1000BASE-T
 						 */
 /* Number of times we will attempt to autonegotiate before downshifting if we
- * are the master */
+ * are the master
+ */
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_MASK 0x0C00
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_1X   0x0000
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_2X   0x0400
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_3X   0x0800
 #define M88E1000_EPSCR_MASTER_DOWNSHIFT_4X   0x0C00
 /* Number of times we will attempt to autonegotiate before downshifting if we
- * are the slave */
+ * are the slave
+ */
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_MASK  0x0300
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_DIS   0x0000
 #define M88E1000_EPSCR_SLAVE_DOWNSHIFT_1X    0x0100
@@ -2891,7 +2896,8 @@ struct e1000_host_command_info {
 
 /* IGP01E1000 GMII FIFO Register */
 #define IGP01E1000_GMII_FLEX_SPD               0x10	/* Enable flexible speed
-							 * on Link-Up */
+							 * on Link-Up
+							 */
 #define IGP01E1000_GMII_SPD                    0x20	/* Enable SPD */
 
 /* IGP01E1000 Analog Register */
@@ -2938,32 +2944,32 @@ struct e1000_host_command_info {
  */
 #define PHY_PAGE_SHIFT        5
 #define PHY_REG(page, reg)    \
-        (((page) << PHY_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))
+	(((page) << PHY_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))
 
 #define IGP3_PHY_PORT_CTRL           \
-        PHY_REG(769, 17)	/* Port General Configuration */
+	PHY_REG(769, 17)	/* Port General Configuration */
 #define IGP3_PHY_RATE_ADAPT_CTRL \
-        PHY_REG(769, 25)	/* Rate Adapter Control Register */
+	PHY_REG(769, 25)	/* Rate Adapter Control Register */
 
 #define IGP3_KMRN_FIFO_CTRL_STATS \
-        PHY_REG(770, 16)	/* KMRN FIFO's control/status register */
+	PHY_REG(770, 16)	/* KMRN FIFO's control/status register */
 #define IGP3_KMRN_POWER_MNG_CTRL \
-        PHY_REG(770, 17)	/* KMRN Power Management Control Register */
+	PHY_REG(770, 17)	/* KMRN Power Management Control Register */
 #define IGP3_KMRN_INBAND_CTRL \
-        PHY_REG(770, 18)	/* KMRN Inband Control Register */
+	PHY_REG(770, 18)	/* KMRN Inband Control Register */
 #define IGP3_KMRN_DIAG \
-        PHY_REG(770, 19)	/* KMRN Diagnostic register */
+	PHY_REG(770, 19)	/* KMRN Diagnostic register */
 #define IGP3_KMRN_DIAG_PCS_LOCK_LOSS 0x0002	/* RX PCS is not synced */
 #define IGP3_KMRN_ACK_TIMEOUT \
-        PHY_REG(770, 20)	/* KMRN Acknowledge Timeouts register */
+	PHY_REG(770, 20)	/* KMRN Acknowledge Timeouts register */
 
 #define IGP3_VR_CTRL \
-        PHY_REG(776, 18)	/* Voltage regulator control register */
+	PHY_REG(776, 18)	/* Voltage regulator control register */
 #define IGP3_VR_CTRL_MODE_SHUT       0x0200	/* Enter powerdown, shutdown VRs */
 #define IGP3_VR_CTRL_MODE_MASK       0x0300	/* Shutdown VR Mask */
 
 #define IGP3_CAPABILITY \
-        PHY_REG(776, 19)	/* IGP3 Capability Register */
+	PHY_REG(776, 19)	/* IGP3 Capability Register */
 
 /* Capabilities for SKU Control  */
 #define IGP3_CAP_INITIATE_TEAM       0x0001	/* Able to initiate a team */
-- 
1.9.1
