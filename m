From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 11/11] misc whitespace cleanup, changelog
Date: Mon, 8 Sep 2003 20:15:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309081957300.1261-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* misc whitespace cleanup, changelog

----------------


diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_ethtool.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_ethtool.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_ethtool.c	2003-08-22 16:55:33.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_ethtool.c	2003-09-08 09:13:10.000000000 -0700
@@ -1173,7 +1173,7 @@ e1000_ethtool_test(struct e1000_adapter 
 			e1000_down(adapter);
 		else
 			e1000_reset(adapter);
-		
+
 		if(e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.c	2003-08-22 17:01:40.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.c	2003-09-08 09:13:11.000000000 -0700
@@ -41,7 +41,8 @@
 static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
 static void e1000_raise_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
 static void e1000_lower_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
-static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, uint32_t data, uint16_t count);
+static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, uint32_t data,
+                                     uint16_t count);
 static uint16_t e1000_shift_in_mdi_bits(struct e1000_hw *hw);
 static int32_t e1000_phy_reset_dsp(struct e1000_hw *hw);
 static int32_t e1000_write_eeprom_spi(struct e1000_hw *hw, uint16_t offset,
@@ -52,7 +52,8 @@ static int32_t e1000_write_eeprom_microw
 static int32_t e1000_spi_eeprom_ready(struct e1000_hw *hw);
 static void e1000_raise_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
 static void e1000_lower_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
-static void e1000_shift_out_ee_bits(struct e1000_hw *hw, uint16_t data, uint16_t count);
+static void e1000_shift_out_ee_bits(struct e1000_hw *hw, uint16_t data,
+                                    uint16_t count);
 static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
                                       uint16_t phy_data);
 static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,uint32_t reg_addr,
@@ -257,7 +218,6 @@ e1000_set_mac_type(struct e1000_hw *hw)
         return -E1000_ERR_MAC_TYPE;
     }
 
-
     return E1000_SUCCESS;
 }
 
@@ -342,20 +280,21 @@ e1000_reset_hw(struct e1000_hw *hw)
      */
     msec_delay(10);
 
-    /* Issue a global reset to the MAC.  This will reset the chip's
-     * transmit, receive, DMA, and link units.  It will not effect
-     * the current PCI configuration.  The global reset bit is self-
-     * clearing, and should clear within a microsecond.
-     */
-    DEBUGOUT("Issuing a global reset to MAC\n");
     ctrl = E1000_READ_REG(hw, CTRL);
 
     /* Must reset the PHY before resetting the MAC */
     if((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
         E1000_WRITE_REG_IO(hw, CTRL, (ctrl | E1000_CTRL_PHY_RST));
-	msec_delay(5);
+        msec_delay(5);
     }
 
+    /* Issue a global reset to the MAC.  This will reset the chip's
+     * transmit, receive, DMA, and link units.  It will not effect
+     * the current PCI configuration.  The global reset bit is self-
+     * clearing, and should clear within a microsecond.
+     */
+    DEBUGOUT("Issuing a global reset to MAC\n");
+
     switch(hw->mac_type) {
         case e1000_82544:
         case e1000_82540:
@@ -3083,7 +3083,8 @@ e1000_shift_out_ee_bits(struct e1000_hw 
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
 static uint16_t
-e1000_shift_in_ee_bits(struct e1000_hw *hw, uint16_t count)
+e1000_shift_in_ee_bits(struct e1000_hw *hw,
+                       uint16_t count)
 {
     uint32_t eecd;
     uint32_t i;
@@ -4359,8 +4362,7 @@ e1000_update_adaptive(struct e1000_hw *h
     DEBUGFUNC("e1000_update_adaptive");
 
     if(hw->adaptive_ifs) {
-        if((hw->collision_delta * hw->ifs_ratio) >
-           hw->tx_packet_delta) {
+        if((hw->collision_delta * hw->ifs_ratio) > hw->tx_packet_delta) {
             if(hw->tx_packet_delta > MIN_NUM_XMITS) {
                 hw->in_ifs_mode = TRUE;
                 if(hw->current_ifs_val < hw->ifs_max_val) {
@@ -4372,8 +4374,7 @@ e1000_update_adaptive(struct e1000_hw *h
                 }
             }
         } else {
-            if((hw->in_ifs_mode == TRUE) &&
-               (hw->tx_packet_delta <= MIN_NUM_XMITS)) {
+            if(hw->in_ifs_mode && (hw->tx_packet_delta <= MIN_NUM_XMITS)) {
                 hw->current_ifs_val = 0;
                 hw->in_ifs_mode = FALSE;
                 E1000_WRITE_REG(hw, AIT, 0);
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000_hw.h	2003-08-22 16:58:59.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_hw.h	2003-09-08 09:13:16.000000000 -0700
@@ -33,9 +33,9 @@
 #ifndef _E1000_HW_H_
 #define _E1000_HW_H_
 
-
 #include "e1000_osdep.h"
 
+
 /* Forward declarations of structures used by the shared code */
 struct e1000_hw;
 struct e1000_hw_stats;
@@ -425,7 +425,7 @@ void e1000_write_reg_io(struct e1000_hw 
     E1000_IMS_RXSEQ  |    \
     E1000_IMS_LSC)
 
-/* The number of high/low register pairs in the RAR. The RAR (Receive Address
+/* Number of high/low register pairs in the RAR. The RAR (Receive Address
  * Registers) holds the directed and multicast addresses that we monitor. We
  * reserve one of these spots for our directed address, allowing us room for
  * E1000_RAR_ENTRIES - 1 multicast addresses.
@@ -579,7 +579,7 @@ struct e1000_rar {
     volatile uint32_t high;     /* receive address high */
 };
 
-/* The number of entries in the Multicast Table Array (MTA). */
+/* Number of entries in the Multicast Table Array (MTA). */
 #define E1000_NUM_MTA_REGISTERS 128
 
 /* IPv4 Address Table Entry */
@@ -1108,7 +1108,7 @@ struct e1000_hw {
 #define E1000_EECD_PRES      0x00000100 /* EEPROM Present */
 #define E1000_EECD_SIZE      0x00000200 /* EEPROM Size (0=64 word 1=256 word) */
 #define E1000_EECD_ADDR_BITS 0x00000400 /* EEPROM Addressing bits based on type
-					 * (0-small, 1-large) */
+                                         * (0-small, 1-large) */
 #define E1000_EECD_TYPE      0x00002000 /* EEPROM Type (1-SPI, 0-Microwire) */
 #ifndef E1000_EEPROM_GRANT_ATTEMPTS
 #define E1000_EEPROM_GRANT_ATTEMPTS 1000 /* EEPROM # attempts to gain grant */
@@ -1170,22 +1170,22 @@ struct e1000_hw {
 #define E1000_MDIC_ERROR     0x40000000
 
 /* LED Control */
-#define E1000_LEDCTL_LED0_MODE_MASK  0x0000000F
-#define E1000_LEDCTL_LED0_MODE_SHIFT 0
-#define E1000_LEDCTL_LED0_IVRT       0x00000040
-#define E1000_LEDCTL_LED0_BLINK      0x00000080
-#define E1000_LEDCTL_LED1_MODE_MASK  0x00000F00
-#define E1000_LEDCTL_LED1_MODE_SHIFT 8
-#define E1000_LEDCTL_LED1_IVRT       0x00004000
-#define E1000_LEDCTL_LED1_BLINK      0x00008000
-#define E1000_LEDCTL_LED2_MODE_MASK  0x000F0000
-#define E1000_LEDCTL_LED2_MODE_SHIFT 16
-#define E1000_LEDCTL_LED2_IVRT       0x00400000
-#define E1000_LEDCTL_LED2_BLINK      0x00800000
-#define E1000_LEDCTL_LED3_MODE_MASK  0x0F000000
-#define E1000_LEDCTL_LED3_MODE_SHIFT 24
-#define E1000_LEDCTL_LED3_IVRT       0x40000000
-#define E1000_LEDCTL_LED3_BLINK      0x80000000
+#define E1000_LEDCTL_LED0_MODE_MASK       0x0000000F
+#define E1000_LEDCTL_LED0_MODE_SHIFT      0
+#define E1000_LEDCTL_LED0_IVRT            0x00000040
+#define E1000_LEDCTL_LED0_BLINK           0x00000080
+#define E1000_LEDCTL_LED1_MODE_MASK       0x00000F00
+#define E1000_LEDCTL_LED1_MODE_SHIFT      8
+#define E1000_LEDCTL_LED1_IVRT            0x00004000
+#define E1000_LEDCTL_LED1_BLINK           0x00008000
+#define E1000_LEDCTL_LED2_MODE_MASK       0x000F0000
+#define E1000_LEDCTL_LED2_MODE_SHIFT      16
+#define E1000_LEDCTL_LED2_IVRT            0x00400000
+#define E1000_LEDCTL_LED2_BLINK           0x00800000
+#define E1000_LEDCTL_LED3_MODE_MASK       0x0F000000
+#define E1000_LEDCTL_LED3_MODE_SHIFT      24
+#define E1000_LEDCTL_LED3_IVRT            0x40000000
+#define E1000_LEDCTL_LED3_BLINK           0x80000000
 
 #define E1000_LEDCTL_MODE_LINK_10_1000  0x0
 #define E1000_LEDCTL_MODE_LINK_100_1000 0x1
@@ -1208,109 +1208,109 @@ struct e1000_hw {
 #define E1000_RAH_AV  0x80000000        /* Receive descriptor valid */
 
 /* Interrupt Cause Read */
-#define E1000_ICR_TXDW    0x00000001    /* Transmit desc written back */
-#define E1000_ICR_TXQE    0x00000002    /* Transmit Queue empty */
-#define E1000_ICR_LSC     0x00000004    /* Link Status Change */
-#define E1000_ICR_RXSEQ   0x00000008    /* rx sequence error */
-#define E1000_ICR_RXDMT0  0x00000010    /* rx desc min. threshold (0) */
-#define E1000_ICR_RXO     0x00000040    /* rx overrun */
-#define E1000_ICR_RXT0    0x00000080    /* rx timer intr (ring 0) */
-#define E1000_ICR_MDAC    0x00000200    /* MDIO access complete */
-#define E1000_ICR_RXCFG   0x00000400    /* RX /c/ ordered set */
-#define E1000_ICR_GPI_EN0 0x00000800    /* GP Int 0 */
-#define E1000_ICR_GPI_EN1 0x00001000    /* GP Int 1 */
-#define E1000_ICR_GPI_EN2 0x00002000    /* GP Int 2 */
-#define E1000_ICR_GPI_EN3 0x00004000    /* GP Int 3 */
-#define E1000_ICR_TXD_LOW 0x00008000
-#define E1000_ICR_SRPD    0x00010000
+#define E1000_ICR_TXDW          0x00000001 /* Transmit desc written back */
+#define E1000_ICR_TXQE          0x00000002 /* Transmit Queue empty */
+#define E1000_ICR_LSC           0x00000004 /* Link Status Change */
+#define E1000_ICR_RXSEQ         0x00000008 /* rx sequence error */
+#define E1000_ICR_RXDMT0        0x00000010 /* rx desc min. threshold (0) */
+#define E1000_ICR_RXO           0x00000040 /* rx overrun */
+#define E1000_ICR_RXT0          0x00000080 /* rx timer intr (ring 0) */
+#define E1000_ICR_MDAC          0x00000200 /* MDIO access complete */
+#define E1000_ICR_RXCFG         0x00000400 /* RX /c/ ordered set */
+#define E1000_ICR_GPI_EN0       0x00000800 /* GP Int 0 */
+#define E1000_ICR_GPI_EN1       0x00001000 /* GP Int 1 */
+#define E1000_ICR_GPI_EN2       0x00002000 /* GP Int 2 */
+#define E1000_ICR_GPI_EN3       0x00004000 /* GP Int 3 */
+#define E1000_ICR_TXD_LOW       0x00008000
+#define E1000_ICR_SRPD          0x00010000
 
 /* Interrupt Cause Set */
-#define E1000_ICS_TXDW    E1000_ICR_TXDW        /* Transmit desc written back */
-#define E1000_ICS_TXQE    E1000_ICR_TXQE        /* Transmit Queue empty */
-#define E1000_ICS_LSC     E1000_ICR_LSC         /* Link Status Change */
-#define E1000_ICS_RXSEQ   E1000_ICR_RXSEQ       /* rx sequence error */
-#define E1000_ICS_RXDMT0  E1000_ICR_RXDMT0      /* rx desc min. threshold */
-#define E1000_ICS_RXO     E1000_ICR_RXO         /* rx overrun */
-#define E1000_ICS_RXT0    E1000_ICR_RXT0        /* rx timer intr */
-#define E1000_ICS_MDAC    E1000_ICR_MDAC        /* MDIO access complete */
-#define E1000_ICS_RXCFG   E1000_ICR_RXCFG       /* RX /c/ ordered set */
-#define E1000_ICS_GPI_EN0 E1000_ICR_GPI_EN0     /* GP Int 0 */
-#define E1000_ICS_GPI_EN1 E1000_ICR_GPI_EN1     /* GP Int 1 */
-#define E1000_ICS_GPI_EN2 E1000_ICR_GPI_EN2     /* GP Int 2 */
-#define E1000_ICS_GPI_EN3 E1000_ICR_GPI_EN3     /* GP Int 3 */
-#define E1000_ICS_TXD_LOW E1000_ICR_TXD_LOW
-#define E1000_ICS_SRPD    E1000_ICR_SRPD
+#define E1000_ICS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
+#define E1000_ICS_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
+#define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_ICS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
+#define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_ICS_RXO       E1000_ICR_RXO       /* rx overrun */
+#define E1000_ICS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_ICS_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
+#define E1000_ICS_RXCFG     E1000_ICR_RXCFG     /* RX /c/ ordered set */
+#define E1000_ICS_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
+#define E1000_ICS_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
+#define E1000_ICS_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
+#define E1000_ICS_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
+#define E1000_ICS_TXD_LOW   E1000_ICR_TXD_LOW
+#define E1000_ICS_SRPD      E1000_ICR_SRPD
 
 /* Interrupt Mask Set */
-#define E1000_IMS_TXDW    E1000_ICR_TXDW        /* Transmit desc written back */
-#define E1000_IMS_TXQE    E1000_ICR_TXQE        /* Transmit Queue empty */
-#define E1000_IMS_LSC     E1000_ICR_LSC         /* Link Status Change */
-#define E1000_IMS_RXSEQ   E1000_ICR_RXSEQ       /* rx sequence error */
-#define E1000_IMS_RXDMT0  E1000_ICR_RXDMT0      /* rx desc min. threshold */
-#define E1000_IMS_RXO     E1000_ICR_RXO         /* rx overrun */
-#define E1000_IMS_RXT0    E1000_ICR_RXT0        /* rx timer intr */
-#define E1000_IMS_MDAC    E1000_ICR_MDAC        /* MDIO access complete */
-#define E1000_IMS_RXCFG   E1000_ICR_RXCFG       /* RX /c/ ordered set */
-#define E1000_IMS_GPI_EN0 E1000_ICR_GPI_EN0     /* GP Int 0 */
-#define E1000_IMS_GPI_EN1 E1000_ICR_GPI_EN1     /* GP Int 1 */
-#define E1000_IMS_GPI_EN2 E1000_ICR_GPI_EN2     /* GP Int 2 */
-#define E1000_IMS_GPI_EN3 E1000_ICR_GPI_EN3     /* GP Int 3 */
-#define E1000_IMS_TXD_LOW E1000_ICR_TXD_LOW
-#define E1000_IMS_SRPD    E1000_ICR_SRPD
+#define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
+#define E1000_IMS_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
+#define E1000_IMS_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_IMS_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
+#define E1000_IMS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_IMS_RXO       E1000_ICR_RXO       /* rx overrun */
+#define E1000_IMS_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_IMS_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
+#define E1000_IMS_RXCFG     E1000_ICR_RXCFG     /* RX /c/ ordered set */
+#define E1000_IMS_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
+#define E1000_IMS_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
+#define E1000_IMS_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
+#define E1000_IMS_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
+#define E1000_IMS_TXD_LOW   E1000_ICR_TXD_LOW
+#define E1000_IMS_SRPD      E1000_ICR_SRPD
 
 /* Interrupt Mask Clear */
-#define E1000_IMC_TXDW    E1000_ICR_TXDW        /* Transmit desc written back */
-#define E1000_IMC_TXQE    E1000_ICR_TXQE        /* Transmit Queue empty */
-#define E1000_IMC_LSC     E1000_ICR_LSC         /* Link Status Change */
-#define E1000_IMC_RXSEQ   E1000_ICR_RXSEQ       /* rx sequence error */
-#define E1000_IMC_RXDMT0  E1000_ICR_RXDMT0      /* rx desc min. threshold */
-#define E1000_IMC_RXO     E1000_ICR_RXO         /* rx overrun */
-#define E1000_IMC_RXT0    E1000_ICR_RXT0        /* rx timer intr */
-#define E1000_IMC_MDAC    E1000_ICR_MDAC        /* MDIO access complete */
-#define E1000_IMC_RXCFG   E1000_ICR_RXCFG       /* RX /c/ ordered set */
-#define E1000_IMC_GPI_EN0 E1000_ICR_GPI_EN0     /* GP Int 0 */
-#define E1000_IMC_GPI_EN1 E1000_ICR_GPI_EN1     /* GP Int 1 */
-#define E1000_IMC_GPI_EN2 E1000_ICR_GPI_EN2     /* GP Int 2 */
-#define E1000_IMC_GPI_EN3 E1000_ICR_GPI_EN3     /* GP Int 3 */
-#define E1000_IMC_TXD_LOW E1000_ICR_TXD_LOW
-#define E1000_IMC_SRPD    E1000_ICR_SRPD
+#define E1000_IMC_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
+#define E1000_IMC_TXQE      E1000_ICR_TXQE      /* Transmit Queue empty */
+#define E1000_IMC_LSC       E1000_ICR_LSC       /* Link Status Change */
+#define E1000_IMC_RXSEQ     E1000_ICR_RXSEQ     /* rx sequence error */
+#define E1000_IMC_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_IMC_RXO       E1000_ICR_RXO       /* rx overrun */
+#define E1000_IMC_RXT0      E1000_ICR_RXT0      /* rx timer intr */
+#define E1000_IMC_MDAC      E1000_ICR_MDAC      /* MDIO access complete */
+#define E1000_IMC_RXCFG     E1000_ICR_RXCFG     /* RX /c/ ordered set */
+#define E1000_IMC_GPI_EN0   E1000_ICR_GPI_EN0   /* GP Int 0 */
+#define E1000_IMC_GPI_EN1   E1000_ICR_GPI_EN1   /* GP Int 1 */
+#define E1000_IMC_GPI_EN2   E1000_ICR_GPI_EN2   /* GP Int 2 */
+#define E1000_IMC_GPI_EN3   E1000_ICR_GPI_EN3   /* GP Int 3 */
+#define E1000_IMC_TXD_LOW   E1000_ICR_TXD_LOW
+#define E1000_IMC_SRPD      E1000_ICR_SRPD
 
 /* Receive Control */
-#define E1000_RCTL_RST          0x00000001      /* Software reset */
-#define E1000_RCTL_EN           0x00000002      /* enable */
-#define E1000_RCTL_SBP          0x00000004      /* store bad packet */
-#define E1000_RCTL_UPE          0x00000008      /* unicast promiscuous enable */
-#define E1000_RCTL_MPE          0x00000010      /* multicast promiscuous enab */
-#define E1000_RCTL_LPE          0x00000020      /* long packet enable */
-#define E1000_RCTL_LBM_NO       0x00000000      /* no loopback mode */
-#define E1000_RCTL_LBM_MAC      0x00000040      /* MAC loopback mode */
-#define E1000_RCTL_LBM_SLP      0x00000080      /* serial link loopback mode */
-#define E1000_RCTL_LBM_TCVR     0x000000C0      /* tcvr loopback mode */
-#define E1000_RCTL_RDMTS_HALF   0x00000000      /* rx desc min threshold size */
-#define E1000_RCTL_RDMTS_QUAT   0x00000100      /* rx desc min threshold size */
-#define E1000_RCTL_RDMTS_EIGTH  0x00000200      /* rx desc min threshold size */
-#define E1000_RCTL_MO_SHIFT     12              /* multicast offset shift */
-#define E1000_RCTL_MO_0         0x00000000      /* multicast offset 11:0 */
-#define E1000_RCTL_MO_1         0x00001000      /* multicast offset 12:1 */
-#define E1000_RCTL_MO_2         0x00002000      /* multicast offset 13:2 */
-#define E1000_RCTL_MO_3         0x00003000      /* multicast offset 15:4 */
-#define E1000_RCTL_MDR          0x00004000      /* multicast desc ring 0 */
-#define E1000_RCTL_BAM          0x00008000      /* broadcast enable */
+#define E1000_RCTL_RST            0x00000001    /* Software reset */
+#define E1000_RCTL_EN             0x00000002    /* enable */
+#define E1000_RCTL_SBP            0x00000004    /* store bad packet */
+#define E1000_RCTL_UPE            0x00000008    /* unicast promiscuous enable */
+#define E1000_RCTL_MPE            0x00000010    /* multicast promiscuous enab */
+#define E1000_RCTL_LPE            0x00000020    /* long packet enable */
+#define E1000_RCTL_LBM_NO         0x00000000    /* no loopback mode */
+#define E1000_RCTL_LBM_MAC        0x00000040    /* MAC loopback mode */
+#define E1000_RCTL_LBM_SLP        0x00000080    /* serial link loopback mode */
+#define E1000_RCTL_LBM_TCVR       0x000000C0    /* tcvr loopback mode */
+#define E1000_RCTL_RDMTS_HALF     0x00000000    /* rx desc min threshold size */
+#define E1000_RCTL_RDMTS_QUAT     0x00000100    /* rx desc min threshold size */
+#define E1000_RCTL_RDMTS_EIGTH    0x00000200    /* rx desc min threshold size */
+#define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
+#define E1000_RCTL_MO_0           0x00000000    /* multicast offset 11:0 */
+#define E1000_RCTL_MO_1           0x00001000    /* multicast offset 12:1 */
+#define E1000_RCTL_MO_2           0x00002000    /* multicast offset 13:2 */
+#define E1000_RCTL_MO_3           0x00003000    /* multicast offset 15:4 */
+#define E1000_RCTL_MDR            0x00004000    /* multicast desc ring 0 */
+#define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
-#define E1000_RCTL_SZ_2048      0x00000000      /* rx buffer size 2048 */
-#define E1000_RCTL_SZ_1024      0x00010000      /* rx buffer size 1024 */
-#define E1000_RCTL_SZ_512       0x00020000      /* rx buffer size 512 */
-#define E1000_RCTL_SZ_256       0x00030000      /* rx buffer size 256 */
+#define E1000_RCTL_SZ_2048        0x00000000    /* rx buffer size 2048 */
+#define E1000_RCTL_SZ_1024        0x00010000    /* rx buffer size 1024 */
+#define E1000_RCTL_SZ_512         0x00020000    /* rx buffer size 512 */
+#define E1000_RCTL_SZ_256         0x00030000    /* rx buffer size 256 */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 1 */
-#define E1000_RCTL_SZ_16384     0x00010000      /* rx buffer size 16384 */
-#define E1000_RCTL_SZ_8192      0x00020000      /* rx buffer size 8192 */
-#define E1000_RCTL_SZ_4096      0x00030000      /* rx buffer size 4096 */
-#define E1000_RCTL_VFE          0x00040000      /* vlan filter enable */
-#define E1000_RCTL_CFIEN        0x00080000      /* canonical form enable */
-#define E1000_RCTL_CFI          0x00100000      /* canonical form indicator */
-#define E1000_RCTL_DPF          0x00400000      /* discard pause frames */
-#define E1000_RCTL_PMCF         0x00800000      /* pass MAC control frames */
-#define E1000_RCTL_BSEX         0x02000000      /* Buffer size extension */
+#define E1000_RCTL_SZ_16384       0x00010000    /* rx buffer size 16384 */
+#define E1000_RCTL_SZ_8192        0x00020000    /* rx buffer size 8192 */
+#define E1000_RCTL_SZ_4096        0x00030000    /* rx buffer size 4096 */
+#define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
+#define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
+#define E1000_RCTL_CFI            0x00100000    /* canonical form indicator */
+#define E1000_RCTL_DPF            0x00400000    /* discard pause frames */
+#define E1000_RCTL_PMCF           0x00800000    /* pass MAC control frames */
+#define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
 
 /* Receive Descriptor */
 #define E1000_RDT_DELAY 0x0000ffff      /* Delay timer (1=1024us) */
@@ -1546,7 +1546,7 @@ struct e1000_hw {
 #define E1000_HDX_COLLISION_DISTANCE    E1000_COLLISION_DISTANCE
 #define E1000_COLD_SHIFT                12
 
-/* The number of Transmit and Receive Descriptors must be a multiple of 8 */
+/* Number of Transmit and Receive Descriptors must be a multiple of 8 */
 #define REQ_TX_DESCRIPTOR_MULTIPLE  8
 #define REQ_RX_DESCRIPTOR_MULTIPLE  8
 
@@ -1613,35 +1613,30 @@ struct e1000_hw {
 #define PCIX_STATUS_HI_MMRBC_2K      0x2
 
 
-/* The number of bits that we need to shift right to move the "pause"
- * bits from the EEPROM (bits 13:12) to the "pause" (bits 8:7) field
- * in the TXCW register
+/* Number of bits required to shift right the "pause" bits from the
+ * EEPROM (bits 13:12) to the "pause" (bits 8:7) field in the TXCW register.
  */
 #define PAUSE_SHIFT 5
 
-/* The number of bits that we need to shift left to move the "SWDPIO"
- * bits from the EEPROM (bits 8:5) to the "SWDPIO" (bits 25:22) field
- * in the CTRL register
+/* Number of bits required to shift left the "SWDPIO" bits from the
+ * EEPROM (bits 8:5) to the "SWDPIO" (bits 25:22) field in the CTRL register.
  */
 #define SWDPIO_SHIFT 17
 
-/* The number of bits that we need to shift left to move the "SWDPIO_EXT"
- * bits from the EEPROM word F (bits 7:4) to the bits 11:8 of The
- * Extended CTRL register.
- * in the CTRL register
+/* Number of bits required to shift left the "SWDPIO_EXT" bits from the
+ * EEPROM word F (bits 7:4) to the bits 11:8 of The Extended CTRL register.
  */
 #define SWDPIO__EXT_SHIFT 4
 
-/* The number of bits that we need to shift left to move the "ILOS"
- * bit from the EEPROM (bit 4) to the "ILOS" (bit 7) field
- * in the CTRL register
+/* Number of bits required to shift left the "ILOS" bit from the EEPROM
+ * (bit 4) to the "ILOS" (bit 7) field in the CTRL register.
  */
 #define ILOS_SHIFT  3
 
 
 #define RECEIVE_BUFFER_ALIGN_SIZE  (256)
 
-/* The number of milliseconds we wait for auto-negotiation to complete */
+/* Number of milliseconds we wait for auto-negotiation to complete */
 #define LINK_UP_TIMEOUT             500
 
 #define E1000_TX_BUFFER_SIZE ((uint32_t)1514)
@@ -1987,7 +1982,6 @@ struct e1000_hw {
 #define M88E1000_EPSCR_TX_CLK_25      0x0070 /* 25  MHz TX_CLK */
 #define M88E1000_EPSCR_TX_CLK_0       0x0000 /* NO  TX_CLK */
 
-
 /* IGP01E1000 Specific Port Config Register - R/W */
 #define IGP01E1000_PSCFR_AUTO_MDIX_PAR_DETECT  0x0010
 #define IGP01E1000_PSCFR_PRE_EN                0x0020
@@ -2061,6 +1984,7 @@ uint16_t e1000_igp_cable_length_table[IG
 #define IGP01E1000_GMII_FLEX_SPD               0x10 /* Enable flexible speed
                                                      * on Link-Up */
 #define IGP01E1000_GMII_SPD                    0x20 /* Enable SPD */
+
 /* IGP01E1000 Analog Register */
 #define IGP01E1000_ANALOG_SPARE_FUSE_STATUS       0x20D1
 #define IGP01E1000_ANALOG_FUSE_STATUS             0x20D0
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_main.c linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c
--- linux-2.6.0-test4/drivers/net/e1000/e1000_main.c	2003-08-22 16:54:23.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_main.c	2003-09-08 09:13:11.000000000 -0700
@@ -30,6 +30,22 @@
 
 /* Change Log
  *
+ * 5.2.16	8/8/03
+ *   o Added support for new controllers: 82545GM, 82546GB, 82541/7_B1
+ *   o Bug fix: reset h/w before first EEPROM read because we don't know
+ *     who may have been messing with the device before we got there.
+ *     [Dave Johnson (ddj -a-t- cascv.brown.edu)]
+ *   o Bug fix: read the correct work from EEPROM to detect programmed
+ *     WoL settings.
+ *   o Bug fix: TSO would hang if space left in FIFO was being miscalculated
+ *     when mss dropped without a correspoding drop in the DMA buffer size.
+ *   o ASF for Fiber nics isn't supported.
+ *   o Bug fix: Workaround added for potential hang with 82544 running in
+ *     PCI-X if send buffer terminates within an evenly-aligned dword.
+ *   o Feature: Add support for ethtool flow control setting.
+ *   o Feature: Add support for ethtool TSO setting.
+ *   o Feature: Increase default Tx Descriptor count to 1024 for >= 82544.
+ *   
  * 5.1.13	5/28/03
  *   o Bug fix: request_irq() failure resulted in freeing resources twice!
  *     [Don Fry (brazilnut@us.ibm.com)]
@@ -39,18 +55,11 @@
  *   o Cleanup: s/int/unsigned int/ for descriptor ring indexes.
  *   
  * 5.1.11	5/6/03
- *   o Feature: Added support for 82546EB (Quad-port) hardware.
- *   o Feature: Added support for Diagnostics through Ethtool.
- *   o Cleanup: Removed /proc support.
- *   o Cleanup: Removed proprietary IDIAG interface.
- *   o Bug fix: TSO bug fixes.
- *
- * 5.0.42	3/5/03
  */
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.1.13-k2";
+char e1000_driver_version[] = "5.2.16-k1";
 char e1000_copyright[] = "Copyright (c) 1999-2003 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -475,7 +484,7 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->phy_info_timer.function = &e1000_update_phy_info;
 	adapter->phy_info_timer.data = (unsigned long) adapter;
 
-	INIT_WORK(&adapter->tx_timeout_task, 
+	INIT_WORK(&adapter->tx_timeout_task,
 		(void (*)(void *))e1000_tx_timeout_task, netdev);
 
 	register_netdev(netdev);
@@ -2078,6 +2087,7 @@ e1000_intr(int irq, void *data, struct p
 		   !e1000_clean_tx_irq(adapter))
 			break;
 #endif
+
 	return IRQ_HANDLED;
 }
 
@@ -2736,7 +2746,7 @@ e1000_notify_reboot(struct notifier_bloc
 	case SYS_DOWN:
 	case SYS_HALT:
 	case SYS_POWER_OFF:
-		while ((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev)) != NULL) {
+		while((pdev = pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pdev))) {
 			if(pci_dev_driver(pdev) == &e1000_driver)
 				e1000_suspend(pdev, 3);
 		}
diff -Nuarp linux-2.6.0-test4/drivers/net/e1000/e1000_osdep.h linux-2.6.0-test4/drivers/net/e1000.new/e1000_osdep.h
--- linux-2.6.0-test4/drivers/net/e1000/e1000_osdep.h	2003-08-22 16:53:13.000000000 -0700
+++ linux-2.6.0-test4/drivers/net/e1000.new/e1000_osdep.h	2003-09-08 09:13:17.000000000 -0700
@@ -55,10 +55,13 @@
 #define CMD_MEM_WRT_INVALIDATE PCI_COMMAND_INVALIDATE
 
 typedef enum {
+#undef FALSE
     FALSE = 0,
+#undef TRUE
     TRUE = 1
 } boolean_t;
 
+#undef ASSERT
 #define ASSERT(x)	if(!(x)) BUG()
 #define MSGOUT(S, A, B)	printk(KERN_DEBUG S "\n", A, B)
 
