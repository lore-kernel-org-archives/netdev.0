From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.4 10/10] e1000: Driver version white space,
 device id, comments & other
Date: Tue, 15 Feb 2005 13:36:18 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151149060.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

10 Driver version number, white space, comments, device id & other changes
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.c net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.c	2005-02-01 23:21:49.121102008 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.c	2005-02-01 23:21:50.444900760 -0800
@@ -1573,7 +1573,8 @@ e1000_phy_force_speed_duplex(struct e100
             if(mii_status_reg & MII_SR_LINK_STATUS) break;
             msec_delay(100);
         }
-        if((i == 0) && (hw->phy_type == e1000_phy_m88)) {
+        if((i == 0) &&
+           (hw->phy_type == e1000_phy_m88)) {
             /* We didn't get link.  Reset the DSP and wait again for link. */
             ret_val = e1000_phy_reset_dsp(hw);
             if(ret_val) {
@@ -2956,8 +2957,7 @@ e1000_phy_m88_get_info(struct e1000_hw *
     /* Check polarity status */
     ret_val = e1000_check_polarity(hw, &polarity);
     if(ret_val)
-        return ret_val;
-
+        return ret_val; 
     phy_info->cable_polarity = polarity;
 
     ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
@@ -4926,8 +4926,7 @@ e1000_check_downshift(struct e1000_hw *h
             return ret_val;
 
         hw->speed_downgraded = (phy_data & IGP01E1000_PLHR_SS_DOWNGRADE) ? 1 : 0;
-    }
-    else if(hw->phy_type == e1000_phy_m88) {
+    } else if(hw->phy_type == e1000_phy_m88) {
         ret_val = e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS,
                                      &phy_data);
         if(ret_val)
diff -up net-drivers-2.4/drivers/net/e1000/e1000_hw.h net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h
--- net-drivers-2.4/drivers/net/e1000/e1000_hw.h	2005-02-01 23:21:49.121102008 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_hw.h	2005-02-01 23:21:50.480895288 -0800
@@ -36,7 +36,6 @@
 #include "e1000_osdep.h"
 
 
-
 /* Forward declarations of structures used by the shared code */
 struct e1000_hw;
 struct e1000_hw_stats;
@@ -370,6 +369,7 @@ int32_t e1000_set_d3_lplu_state(struct e
 #define E1000_DEV_ID_82546GB_SERDES      0x107B
 #define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82547EI             0x1019
+
 #define NODE_ADDRESS_SIZE 6
 #define ETH_LENGTH_OF_ADDRESS 6
 
@@ -1735,6 +1735,9 @@ struct e1000_hw {
 #define PHY_1000T_STATUS 0x0A /* 1000Base-T Status Reg */
 #define PHY_EXT_STATUS   0x0F /* Extended Status Reg */
 
+#define MAX_PHY_REG_ADDRESS        0x1F  /* 5 bit address bus (0-0x1F) */
+#define MAX_PHY_MULTI_PAGE_REG     0xF   /* Registers equal on all pages */
+
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
 #define M88E1000_PHY_SPEC_STATUS   0x11  /* PHY Specific Status Register */
@@ -1795,8 +1798,7 @@ struct e1000_hw {
 
 #define IGP01E1000_ANALOG_REGS_PAGE  0x20C0
 
-#define MAX_PHY_REG_ADDRESS 0x1F        /* 5 bit address bus (0-0x1F) */
-#define MAX_PHY_MULTI_PAGE_REG  0xF     /*Registers that are equal on all pages*/
+
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB 0x0040  /* bits 6,13: 10=1000, 01=100, 00=10 */
 #define MII_CR_COLL_TEST_ENABLE 0x0080  /* Collision test enable */
@@ -2099,7 +2101,11 @@ struct e1000_hw {
 #define IGP01E1000_ANALOG_FUSE_FINE_1               0x0080
 #define IGP01E1000_ANALOG_FUSE_FINE_10              0x0500
 
+
 /* Bit definitions for valid PHY IDs. */
+/* I = Integrated
+ * E = External
+ */
 #define M88E1000_E_PHY_ID  0x01410C50
 #define M88E1000_I_PHY_ID  0x01410C30
 #define M88E1011_I_PHY_ID  0x01410C20
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2005-02-01 23:21:49.122101856 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:21:50.517889664 -0800
@@ -34,6 +34,14 @@
  * - if_mii support and associated kcompat for older kernels
  * - More errlogging support from Jon Mason <jonmason@us.ibm.com>
  * - Fix TSO issues on PPC64 machines -- Jon Mason <jonmason@us.ibm.com>
+ * 5.7.1	12/16/04
+ * - Resurrect 82547EI/GI related fix in e1000_intr to avoid deadlocks. This
+ *   fix was removed as it caused system instability. The suspected cause of 
+ *   this is the called to e1000_irq_disable in e1000_intr. Inlined the 
+ *   required piece of e1000_irq_disable into e1000_intr.
+ * 5.7.0	12/10/04
+ * - include fix to the condition that determines when to quit NAPI - Robert Olsson
+ * - use netif_poll_{disable/enable} to synchronize between NAPI and i/f up/down
  * 5.6.5 	11/01/04
  * - Enabling NETIF_F_SG without checksum offload is illegal - 
      John Mason <jdmason@us.ibm.com>
@@ -41,8 +41,13 @@ 
  * - Remove redundant initialization - Jamal Hadi
  * - Reset buffer_info->dma in tx resource cleanup logic
  * 5.6.2	10/12/04
+ * - Avoid filling tx_ring completely - shemminger@osdl.org
+ * - Replace schedule_timeout() with msleep()/msleep_interruptible() -
+ *   nacc@us.ibm.com
  * - Sparse cleanup - shemminger@osdl.org
  * - Fix tx resource cleanup logic
+ * - LLTX support - ak@suse.de and hadi@cyberus.ca
+ * - {set, get}_wol is now symmetric for 82545EM adapters
  */
 
 char e1000_driver_name[] = "e1000";
@@ -52,7 +52,7 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.6.10.1-k1"DRIVERNAPI;
+char e1000_driver_version[] = "5.7.6-k1"DRIVERNAPI;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -76,6 +89,7 @@ static struct pci_device_id e1000_pci_tb
 	INTEL_E1000_ETHERNET_DEVICE(0x1011),
 	INTEL_E1000_ETHERNET_DEVICE(0x1012),
 	INTEL_E1000_ETHERNET_DEVICE(0x1013),
+	INTEL_E1000_ETHERNET_DEVICE(0x1014),
 	INTEL_E1000_ETHERNET_DEVICE(0x1015),
 	INTEL_E1000_ETHERNET_DEVICE(0x1016),
 	INTEL_E1000_ETHERNET_DEVICE(0x1017),
@@ -513,9 +527,6 @@ e1000_probe(struct pci_dev *pdev,
 	}
 
 #ifdef NETIF_F_TSO
-	/* Disbaled for now until root-cause is found for
-	 * hangs reported against non-IA archs.  TSO can be
-	 * enabled using ethtool -K eth<x> tso on */
 	if((adapter->hw.mac_type >= e1000_82544) &&
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
@@ -1019,7 +984,7 @@ e1000_setup_rx_resources(struct e1000_ad
 	if(!rxdr->desc) {
 setup_rx_desc_die:
 		DPRINTK(PROBE, ERR, 
-		"Unable to Allocate Memory for the Recieve descriptor ring\n");
+		"Unble to Allocate Memory for the Recieve descriptor ring\n");
 		vfree(rxdr->buffer_info);
 		return -ENOMEM;
 	}
	
