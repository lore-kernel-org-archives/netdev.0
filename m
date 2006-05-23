From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/6] e1000: remove leading and trailing whitespace.
Date: Tue, 23 May 2006 14:08:45 -0700
Message-ID: <20060523210844.18540.33266.stgit@gitlost.site>
References: <20060523210740.18540.56647.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:59909 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932255AbWEWVDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 17:03:47 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523210740.18540.56647.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some leading and trailing whitespace made it into the driver code here.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   44 +++++++++----------
 drivers/net/e1000/e1000_hw.c      |   88 +++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |    4 +-
 drivers/net/e1000/e1000_main.c    |   26 +++++------
 4 files changed, 81 insertions(+), 81 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index e48dc57..cfdf0b2 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -865,15 +865,15 @@ static int
 e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	struct net_device *netdev = adapter->netdev;
- 	uint32_t mask, i=0, shared_int = TRUE;
- 	uint32_t irq = adapter->pdev->irq;
+	uint32_t mask, i=0, shared_int = TRUE;
+	uint32_t irq = adapter->pdev->irq;
 
 	*data = 0;
 
 	/* Hook up test interrupt handler just for this test */
- 	if (!request_irq(irq, &e1000_test_intr, 0, netdev->name, netdev)) {
- 		shared_int = FALSE;
- 	} else if (request_irq(irq, &e1000_test_intr, SA_SHIRQ,
+	if (!request_irq(irq, &e1000_test_intr, 0, netdev->name, netdev)) {
+		shared_int = FALSE;
+	} else if (request_irq(irq, &e1000_test_intr, SA_SHIRQ,
 			      netdev->name, netdev)){
 		*data = 1;
 		return -1;
@@ -889,22 +889,22 @@ e1000_intr_test(struct e1000_adapter *ad
 		/* Interrupt to test */
 		mask = 1 << i;
 
- 		if (!shared_int) {
- 			/* Disable the interrupt to be reported in
- 			 * the cause register and then force the same
- 			 * interrupt and see if one gets posted.  If
- 			 * an interrupt was posted to the bus, the
- 			 * test failed.
- 			 */
- 			adapter->test_icr = 0;
- 			E1000_WRITE_REG(&adapter->hw, IMC, mask);
- 			E1000_WRITE_REG(&adapter->hw, ICS, mask);
- 			msec_delay(10);
-
- 			if (adapter->test_icr & mask) {
- 				*data = 3;
- 				break;
- 			}
+		if (!shared_int) {
+			/* Disable the interrupt to be reported in
+			 * the cause register and then force the same
+			 * interrupt and see if one gets posted.  If
+			 * an interrupt was posted to the bus, the
+			 * test failed.
+			 */
+			adapter->test_icr = 0;
+			E1000_WRITE_REG(&adapter->hw, IMC, mask);
+			E1000_WRITE_REG(&adapter->hw, ICS, mask);
+			msec_delay(10);
+
+			if (adapter->test_icr & mask) {
+				*data = 3;
+				break;
+			}
 		}
 
 		/* Enable the interrupt to be reported in
@@ -923,7 +923,7 @@ e1000_intr_test(struct e1000_adapter *ad
 			break;
 		}
 
- 		if (!shared_int) {
+		if (!shared_int) {
 			/* Disable the other interrupts to be reported in
 			 * the cause register and then force the other
 			 * interrupts and see if any get posted.  If
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 2e211df..3959039 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -765,7 +765,7 @@ e1000_init_hw(struct e1000_hw *hw)
     }
 
     if (hw->mac_type == e1000_82573) {
-        e1000_enable_tx_pkt_filtering(hw); 
+        e1000_enable_tx_pkt_filtering(hw);
     }
 
     switch (hw->mac_type) {
@@ -861,7 +861,7 @@ e1000_adjust_serdes_amplitude(struct e10
 
     if(eeprom_data != EEPROM_RESERVED_WORD) {
         /* Adjust SERDES output amplitude only. */
-        eeprom_data &= EEPROM_SERDES_AMPLITUDE_MASK; 
+        eeprom_data &= EEPROM_SERDES_AMPLITUDE_MASK;
         ret_val = e1000_write_phy_reg(hw, M88E1000_PHY_EXT_CTRL, eeprom_data);
         if(ret_val)
             return ret_val;
@@ -1228,7 +1228,7 @@ e1000_copper_link_igp_setup(struct e1000
 
     if (hw->phy_reset_disable)
         return E1000_SUCCESS;
-    
+
     ret_val = e1000_phy_reset(hw);
     if (ret_val) {
         DEBUGOUT("Error Resetting the PHY\n");
@@ -1370,7 +1370,7 @@ e1000_copper_link_ggp_setup(struct e1000
     DEBUGFUNC("e1000_copper_link_ggp_setup");
 
     if(!hw->phy_reset_disable) {
-        
+
         /* Enable CRS on TX for half-duplex operation. */
         ret_val = e1000_read_phy_reg(hw, GG82563_PHY_MAC_SPEC_CTRL,
                                      &phy_data);
@@ -1519,7 +1519,7 @@ e1000_copper_link_mgp_setup(struct e1000
 
     if(hw->phy_reset_disable)
         return E1000_SUCCESS;
-    
+
     /* Enable CRS on TX. This must be set for half-duplex operation. */
     ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
     if(ret_val)
@@ -1665,7 +1665,7 @@ e1000_copper_link_autoneg(struct e1000_h
 *      collision distance in the Transmit Control Register.
 *   2) Set up flow control on the MAC to that established with
 *      the link partner.
-*   3) Config DSP to improve Gigabit link quality for some PHY revisions.    
+*   3) Config DSP to improve Gigabit link quality for some PHY revisions.
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
@@ -1674,7 +1674,7 @@ e1000_copper_link_postconfig(struct e100
 {
     int32_t ret_val;
     DEBUGFUNC("e1000_copper_link_postconfig");
-    
+
     if(hw->mac_type >= e1000_82544) {
         e1000_config_collision_dist(hw);
     } else {
@@ -1698,7 +1698,7 @@ e1000_copper_link_postconfig(struct e100
             return ret_val;
         }
     }
-                
+
     return E1000_SUCCESS;
 }
 
@@ -1754,11 +1754,11 @@ e1000_setup_copper_link(struct e1000_hw 
     }
 
     if(hw->autoneg) {
-        /* Setup autoneg and flow control advertisement 
-          * and perform autonegotiation */   
+        /* Setup autoneg and flow control advertisement
+          * and perform autonegotiation */
         ret_val = e1000_copper_link_autoneg(hw);
         if(ret_val)
-            return ret_val;           
+            return ret_val;
     } else {
         /* PHY will be set to 10H, 10F, 100H,or 100F
           * depending on value from forced_speed_duplex. */
@@ -1786,7 +1786,7 @@ e1000_setup_copper_link(struct e1000_hw 
             ret_val = e1000_copper_link_postconfig(hw);
             if(ret_val)
                 return ret_val;
-            
+
             DEBUGOUT("Valid link established!!!\n");
             return E1000_SUCCESS;
         }
@@ -1984,7 +1984,7 @@ e1000_phy_setup_autoneg(struct e1000_hw 
 
     DEBUGOUT1("Auto-Neg Advertising %x\n", mii_autoneg_adv_reg);
 
-    ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);    
+    ret_val = e1000_write_phy_reg(hw, PHY_1000T_CTRL, mii_1000t_ctrl_reg);
     if(ret_val)
         return ret_val;
 
@@ -2273,7 +2273,7 @@ e1000_config_mac_to_phy(struct e1000_hw 
 
     DEBUGFUNC("e1000_config_mac_to_phy");
 
-    /* 82544 or newer MAC, Auto Speed Detection takes care of 
+    /* 82544 or newer MAC, Auto Speed Detection takes care of
     * MAC speed/duplex configuration.*/
     if (hw->mac_type >= e1000_82544)
         return E1000_SUCCESS;
@@ -2292,9 +2292,9 @@ e1000_config_mac_to_phy(struct e1000_hw 
     if(ret_val)
         return ret_val;
 
-    if(phy_data & M88E1000_PSSR_DPLX) 
+    if(phy_data & M88E1000_PSSR_DPLX)
         ctrl |= E1000_CTRL_FD;
-    else 
+    else
         ctrl &= ~E1000_CTRL_FD;
 
     e1000_config_collision_dist(hw);
@@ -2884,7 +2884,7 @@ e1000_get_speed_and_duplex(struct e1000_
         }
     }
 
-    if ((hw->mac_type == e1000_80003es2lan) && 
+    if ((hw->mac_type == e1000_80003es2lan) &&
         (hw->media_type == e1000_media_type_copper)) {
         if (*speed == SPEED_1000)
             ret_val = e1000_configure_kmrn_for_1000(hw);
@@ -3160,7 +3160,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
     if (e1000_swfw_sync_acquire(hw, swfw))
         return -E1000_ERR_SWFW_SYNC;
 
-    if((hw->phy_type == e1000_phy_igp || 
+    if((hw->phy_type == e1000_phy_igp ||
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -3299,7 +3299,7 @@ e1000_write_phy_reg(struct e1000_hw *hw,
     if (e1000_swfw_sync_acquire(hw, swfw))
         return -E1000_ERR_SWFW_SYNC;
 
-    if((hw->phy_type == e1000_phy_igp || 
+    if((hw->phy_type == e1000_phy_igp ||
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
@@ -3497,22 +3497,22 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
         }
         /* Read the device control register and assert the E1000_CTRL_PHY_RST
          * bit. Then, take it out of reset.
-         * For pre-e1000_82571 hardware, we delay for 10ms between the assert 
+         * For pre-e1000_82571 hardware, we delay for 10ms between the assert
          * and deassert.  For e1000_82571 hardware and later, we instead delay
          * for 50us between and 10ms after the deassertion.
          */
         ctrl = E1000_READ_REG(hw, CTRL);
         E1000_WRITE_REG(hw, CTRL, ctrl | E1000_CTRL_PHY_RST);
         E1000_WRITE_FLUSH(hw);
-        
-        if (hw->mac_type < e1000_82571) 
+
+        if (hw->mac_type < e1000_82571)
             msec_delay(10);
         else
             udelay(100);
-        
+
         E1000_WRITE_REG(hw, CTRL, ctrl);
         E1000_WRITE_FLUSH(hw);
-        
+
         if (hw->mac_type >= e1000_82571)
             msec_delay(10);
         e1000_swfw_sync_release(hw, swfw);
@@ -3816,7 +3816,7 @@ e1000_phy_m88_get_info(struct e1000_hw *
     /* Check polarity status */
     ret_val = e1000_check_polarity(hw, &polarity);
     if(ret_val)
-        return ret_val; 
+        return ret_val;
     phy_info->cable_polarity = polarity;
 
     ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
@@ -4541,14 +4541,14 @@ e1000_read_eeprom_eerd(struct e1000_hw *
 
         E1000_WRITE_REG(hw, EERD, eerd);
         error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_READ);
-        
+
         if(error) {
             break;
         }
         data[i] = (E1000_READ_REG(hw, EERD) >> E1000_EEPROM_RW_REG_DATA);
-      
+
     }
-    
+
     return error;
 }
 
@@ -4574,24 +4574,24 @@ e1000_write_eeprom_eewr(struct e1000_hw 
         return -E1000_ERR_SWFW_SYNC;
 
     for (i = 0; i < words; i++) {
-        register_value = (data[i] << E1000_EEPROM_RW_REG_DATA) | 
-                         ((offset+i) << E1000_EEPROM_RW_ADDR_SHIFT) | 
+        register_value = (data[i] << E1000_EEPROM_RW_REG_DATA) |
+                         ((offset+i) << E1000_EEPROM_RW_ADDR_SHIFT) |
                          E1000_EEPROM_RW_REG_START;
 
         error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_WRITE);
         if(error) {
             break;
-        }       
+        }
 
         E1000_WRITE_REG(hw, EEWR, register_value);
-        
+
         error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_WRITE);
-        
+
         if(error) {
             break;
-        }       
+        }
     }
-    
+
     e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
     return error;
 }
@@ -4611,7 +4611,7 @@ e1000_poll_eerd_eewr_done(struct e1000_h
     for(i = 0; i < attempts; i++) {
         if(eerd == E1000_EEPROM_POLL_READ)
             reg = E1000_READ_REG(hw, EERD);
-        else 
+        else
             reg = E1000_READ_REG(hw, EEWR);
 
         if(reg & E1000_EEPROM_RW_REG_DONE) {
@@ -5136,7 +5136,7 @@ e1000_mc_addr_list_update(struct e1000_h
     uint32_t i;
     uint32_t num_rar_entry;
     uint32_t num_mta_entry;
-    
+
     DEBUGFUNC("e1000_mc_addr_list_update");
 
     /* Set the new number of MC addresses that we are being requested to use. */
@@ -6241,7 +6241,7 @@ e1000_check_polarity(struct e1000_hw *hw
  *                                1 - Downshift ocured.
  *
  * returns: - E1000_ERR_XXX
- *            E1000_SUCCESS 
+ *            E1000_SUCCESS
  *
  * For phy's older then IGP, this function reads the Downshift bit in the Phy
  * Specific Status register.  For IGP phy's, it reads the Downgrade bit in the
@@ -6256,7 +6256,7 @@ e1000_check_downshift(struct e1000_hw *h
 
     DEBUGFUNC("e1000_check_downshift");
 
-    if(hw->phy_type == e1000_phy_igp || 
+    if(hw->phy_type == e1000_phy_igp ||
         hw->phy_type == e1000_phy_igp_2) {
         ret_val = e1000_read_phy_reg(hw, IGP01E1000_PHY_LINK_HEALTH,
                                      &phy_data);
@@ -6685,8 +6685,8 @@ e1000_set_d0_lplu_state(struct e1000_hw 
 
 
     } else {
- 
-            phy_data |= IGP02E1000_PM_D0_LPLU;   
+
+            phy_data |= IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
             if (ret_val)
                 return ret_val;
@@ -6778,7 +6778,7 @@ int32_t
 e1000_host_if_read_cookie(struct e1000_hw * hw, uint8_t *buffer)
 {
     uint8_t i;
-    uint32_t offset = E1000_MNG_DHCP_COOKIE_OFFSET; 
+    uint32_t offset = E1000_MNG_DHCP_COOKIE_OFFSET;
     uint8_t length = E1000_MNG_DHCP_COOKIE_LENGTH;
 
     length = (length >> 2);
@@ -6797,7 +6797,7 @@ e1000_host_if_read_cookie(struct e1000_h
  * and also checks whether the previous command is completed.
  * It busy waits in case of previous command is not completed.
  *
- * returns: - E1000_ERR_HOST_INTERFACE_COMMAND in case if is not ready or 
+ * returns: - E1000_ERR_HOST_INTERFACE_COMMAND in case if is not ready or
  *            timeout
  *          - E1000_SUCCESS for success.
  ****************************************************************************/
@@ -6821,7 +6821,7 @@ e1000_mng_enable_host_if(struct e1000_hw
         msec_delay_irq(1);
     }
 
-    if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) { 
+    if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
         DEBUGOUT("Previous command timeout failed .\n");
         return -E1000_ERR_HOST_INTERFACE_COMMAND;
     }
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 03d07eb..467c9ed 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -375,7 +375,7 @@ struct e1000_host_mng_dhcp_cookie{
 };
 #endif
 
-int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, uint8_t *buffer, 
+int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, uint8_t *buffer,
 							uint16_t length);
 boolean_t e1000_check_mng_mode(struct e1000_hw *hw);
 boolean_t e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
@@ -1802,7 +1802,7 @@ struct e1000_hw {
  *       value2 = [0..64512],    default=4096
  *       value3 = [0..64512],    default=0
  */
-    
+
 #define E1000_PSRCTL_BSIZE0_MASK   0x0000007F
 #define E1000_PSRCTL_BSIZE1_MASK   0x00003F00
 #define E1000_PSRCTL_BSIZE2_MASK   0x003F0000
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index df819c1..ccbe342 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -349,7 +349,7 @@ e1000_update_mng_vlan(struct e1000_adapt
  * For ASF and Pass Through versions of f/w this means that the
  * driver is no longer loaded. For AMT version (only with 82573) i
  * of the f/w this means that the netowrk i/f is closed.
- * 
+ *
  **/
 
 static void
@@ -381,10 +381,10 @@ e1000_release_hw_control(struct e1000_ad
  * @adapter: address of board private structure
  *
  * e1000_get_hw_control sets {CTRL_EXT|FWSM}:DRV_LOAD bit.
- * For ASF and Pass Through versions of f/w this means that 
- * the driver is loaded. For AMT version (only with 82573) 
+ * For ASF and Pass Through versions of f/w this means that
+ * the driver is loaded. For AMT version (only with 82573)
  * of the f/w this means that the netowrk i/f is open.
- * 
+ *
  **/
 
 static void
@@ -714,8 +714,8 @@ e1000_probe(struct pci_dev *pdev,
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
 	/* if ksp3, indicate if it's port a being setup */
-	if (pdev->device == E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 && 
-			e1000_ksp3_port_a == 0) 
+	if (pdev->device == E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 &&
+			e1000_ksp3_port_a == 0)
 		adapter->ksp3_port_a = 1;
 	e1000_ksp3_port_a++;
 	/* Reset for multiple KP3 adapters */
@@ -743,9 +743,9 @@ e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
- 	/* hard_start_xmit is safe against parallel locking */
- 	netdev->features |= NETIF_F_LLTX; 
- 
+	/* hard_start_xmit is safe against parallel locking */
+	netdev->features |= NETIF_F_LLTX;
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* before reading the EEPROM, reset the controller to
@@ -2773,7 +2773,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
- 	int tso;
+	int tso;
 	unsigned int f;
 	len -= skb->data_len;
 
@@ -2786,7 +2786,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 #ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->tso_size;
-	/* The controller does a simple calculation to 
+	/* The controller does a simple calculation to
 	 * make sure there is enough room in the FIFO before
 	 * initiating the DMA for each buffer.  The calc is:
 	 * 4 = ceil(buffer len/mss).  To make sure we don't
@@ -2809,7 +2809,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 			case e1000_82573:
 				pull_size = min((unsigned int)4, skb->data_len);
 				if (!__pskb_pull_tail(skb, pull_size)) {
-					printk(KERN_ERR 
+					printk(KERN_ERR
 						"__pskb_pull_tail failed.\n");
 					dev_kfree_skb_any(skb);
 					return NETDEV_TX_OK;
@@ -3755,7 +3755,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapt
 		 * throughput, so unsplit small packets and save the alloc/put*/
 		if (l1 && ((length + l1) <= adapter->rx_ps_bsize0)) {
 			u8 *vaddr;
-			/* there is no documentation about how to call 
+			/* there is no documentation about how to call
 			 * kmap_atomic, so we can't hold the mapping
 			 * very long */
 			pci_dma_sync_single_for_cpu(pdev,



--
Auke Kok <auke-jan.h.kok@intel.com>
