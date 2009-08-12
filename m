From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 35/36] bnx2x: Whitespaces and comments
Date: Wed, 12 Aug 2009 21:24:29 +0300
Message-ID: <1250101469.27379.187.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3470 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753419AbZHLSZZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   38 ++++++++-------
 drivers/net/bnx2x_link.c |  115 +++++++++++++++++++++++-----------------------
 drivers/net/bnx2x_main.c |   80 ++++++++++++++++----------------
 drivers/net/bnx2x_reg.h  |    3 +-
 4 files changed, 121 insertions(+), 115 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 97bc5e0..bbf8422 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -314,9 +314,11 @@ struct bnx2x_fastpath {
 	__le16			*rx_cons_sb;
 	__le16			*rx_bd_cons_sb;
 
+
 	unsigned long		tx_pkt,
 				rx_pkt,
 				rx_calls;
+
 	/* TPA related */
 	struct sw_rx_bd		tpa_pool[ETH_MAX_AGGREGATION_QUEUES_E1H];
 	u8			tpa_state[ETH_MAX_AGGREGATION_QUEUES_E1H];
@@ -998,20 +1000,20 @@ struct bnx2x {
 #define GUNZIP_PHYS(bp)			(bp->gunzip_mapping)
 #define GUNZIP_OUTLEN(bp)		(bp->gunzip_outlen)
 
-	struct raw_op          *init_ops;
+	struct raw_op		*init_ops;
 	/* Init blocks offsets inside init_ops */
-	u16                    *init_ops_offsets;
+	u16			*init_ops_offsets;
 	/* Data blob - has 32 bit granularity */
-	u32                    *init_data;
+	u32			*init_data;
 	/* Zipped PRAM blobs - raw data */
-	const u8               *tsem_int_table_data;
-	const u8               *tsem_pram_data;
-	const u8               *usem_int_table_data;
-	const u8               *usem_pram_data;
-	const u8               *xsem_int_table_data;
-	const u8               *xsem_pram_data;
-	const u8               *csem_int_table_data;
-	const u8               *csem_pram_data;
+	const u8		*tsem_int_table_data;
+	const u8		*tsem_pram_data;
+	const u8		*usem_int_table_data;
+	const u8		*usem_pram_data;
+	const u8		*xsem_int_table_data;
+	const u8		*xsem_pram_data;
+	const u8		*csem_int_table_data;
+	const u8		*csem_pram_data;
 #define INIT_OPS(bp)			(bp->init_ops)
 #define INIT_OPS_OFFSETS(bp)		(bp->init_ops_offsets)
 #define INIT_DATA(bp)			(bp->init_data)
@@ -1024,7 +1026,7 @@ struct bnx2x {
 #define INIT_CSEM_INT_TABLE_DATA(bp)	(bp->csem_int_table_data)
 #define INIT_CSEM_PRAM_DATA(bp)		(bp->csem_pram_data)
 
-        const struct firmware  *firmware;
+	const struct firmware	*firmware;
 };
 
 
@@ -1111,9 +1113,9 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 #define DMAE_COMP_VAL			0xe0d0d0ae
 
 #define MAX_DMAE_C_PER_PORT		8
-#define INIT_DMAE_C(bp)			(BP_PORT(bp)*MAX_DMAE_C_PER_PORT + \
+#define INIT_DMAE_C(bp)			(BP_PORT(bp) * MAX_DMAE_C_PER_PORT + \
 					 BP_E1HVN(bp))
-#define PMF_DMAE_C(bp)			(BP_PORT(bp)*MAX_DMAE_C_PER_PORT + \
+#define PMF_DMAE_C(bp)			(BP_PORT(bp) * MAX_DMAE_C_PER_PORT + \
 					 E1HVN_MAX)
 
 
@@ -1138,7 +1140,8 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 
 
 /* must be used on a CID before placing it on a HW ring */
-#define HW_CID(bp, x)		((BP_PORT(bp) << 23) | (BP_E1HVN(bp) << 17) | x)
+#define HW_CID(bp, x)			((BP_PORT(bp) << 23) | \
+					 (BP_E1HVN(bp) << 17) | (x))
 
 #define SP_DESC_CNT		(BCM_PAGE_SIZE / sizeof(struct eth_spe))
 #define MAX_SP_DESC_CNT			(SP_DESC_CNT - 1)
@@ -1226,8 +1229,8 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 				 AEU_INPUTS_ATTN_BITS_QM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_XSDM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_XSEMI_PARITY_ERROR | \
-				AEU_INPUTS_ATTN_BITS_DOORBELLQ_PARITY_ERROR |\
-			    AEU_INPUTS_ATTN_BITS_VAUX_PCI_CORE_PARITY_ERROR |\
+				 AEU_INPUTS_ATTN_BITS_DOORBELLQ_PARITY_ERROR |\
+			     AEU_INPUTS_ATTN_BITS_VAUX_PCI_CORE_PARITY_ERROR |\
 				 AEU_INPUTS_ATTN_BITS_DEBUG_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_USDM_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_USEMI_PARITY_ERROR | \
@@ -1255,7 +1258,6 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 		 TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY | \
 		 (bp->multi_mode << \
 		  TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT))
-
 #define MULTI_MASK			0x7f
 
 
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index c2b0010..e32d337 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -182,6 +182,7 @@ static void bnx2x_set_serdes_access(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u32 emac_base = (params->port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+
 	/* Set Clause 22 */
 	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + params->port*0x10, 1);
 	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245f8000);
@@ -194,6 +195,7 @@ static void bnx2x_set_serdes_access(struct link_params *params)
 static void bnx2x_set_phy_mdio(struct link_params *params, u8 phy_flags)
 {
 	struct bnx2x *bp = params->bp;
+
 	if (phy_flags & PHY_XGXS_FLAG) {
 		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
 			   params->port*0x18, 0);
@@ -465,7 +467,6 @@ static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL,
 		    wb_data, 2);
 
-
 	/* set rx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
@@ -684,6 +685,7 @@ void bnx2x_link_status_update(struct link_params *params,
 static void bnx2x_update_mng(struct link_params *params, u32 link_status)
 {
 	struct bnx2x *bp = params->bp;
+
 	REG_WR(bp, params->shmem_base +
 		   offsetof(struct shmem_region,
 			    port_mb[params->port].link_status),
@@ -780,7 +782,6 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 			DP(NETIF_MSG_LINK, "Invalid line_speed 0x%x\n",
 				  line_speed);
 			return -EINVAL;
-			break;
 		}
 	}
 	REG_WR(bp, PBF_REG_P0_INIT_CRD + port*4, init_crd);
@@ -800,6 +801,7 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 static u32 bnx2x_get_emac_base(struct bnx2x *bp, u32 ext_phy_type, u8 port)
 {
 	u32 emac_base;
+
 	switch (ext_phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
@@ -905,7 +907,7 @@ u8 bnx2x_cl45_read(struct bnx2x *bp, u8 port, u32 ext_phy_type,
 	val = saved_mode & ((EMAC_MDIO_MODE_AUTO_POLL |
 			     EMAC_MDIO_MODE_CLOCK_CNT));
 	val |= (EMAC_MDIO_MODE_CLAUSE_45 |
-		(49 << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
+		(49L << EMAC_MDIO_MODE_CLOCK_CNT_BITSHIFT));
 	REG_WR(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE, val);
 	REG_RD(bp, mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE);
 	udelay(40);
@@ -1535,14 +1537,14 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 	}
 }
 
-static u8 bnx2x_ext_phy_resove_fc(struct link_params *params,
+static u8 bnx2x_ext_phy_resolve_fc(struct link_params *params,
 				  struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u8 ext_phy_addr;
-	u16 ld_pause;	/* local */
-	u16 lp_pause;	/* link partner */
-	u16 an_complete; /* AN complete */
+	u16 ld_pause;		/* local */
+	u16 lp_pause;		/* link partner */
+	u16 an_complete;	/* AN complete */
 	u16 pause_result;
 	u8 ret = 0;
 	u32 ext_phy_type;
@@ -1642,7 +1644,7 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 		DP(NETIF_MSG_LINK, "pause_result 0x%x\n", pause_result);
 		bnx2x_pause_resolve(vars, pause_result);
 	} else if ((params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
-		   (bnx2x_ext_phy_resove_fc(params, vars))) {
+		   (bnx2x_ext_phy_resolve_fc(params, vars))) {
 		return;
 	} else {
 		if (params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO)
@@ -1784,7 +1786,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 				 "link speed unsupported  gp_status 0x%x\n",
 				  gp_status);
 			return -EINVAL;
-			break;
+
 		case GP_STATUS_10G_KX4:
 		case GP_STATUS_10G_HIG:
 		case GP_STATUS_10G_CX4:
@@ -1821,8 +1823,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 			DP(NETIF_MSG_LINK,
 				  "link speed unsupported gp_status 0x%x\n",
 				  gp_status);
-		return -EINVAL;
-			break;
+			return -EINVAL;
 		}
 
 		/* Upon link speed change set the NIG into drain mode.
@@ -2061,16 +2062,17 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_CTRL,
 				       1<<15);
-
 			break;
+
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+			DP(NETIF_MSG_LINK, "XGXS 8072\n");
+
 			/* Unset Low Power Mode and SW reset */
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 					  params->port);
 
-			DP(NETIF_MSG_LINK, "XGXS 8072\n");
 			bnx2x_cl45_write(bp, params->port,
 				       ext_phy_type,
 				       ext_phy_addr,
@@ -2078,8 +2080,9 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 				       MDIO_PMA_REG_CTRL,
 				       1<<15);
 			break;
+
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-			{
+			DP(NETIF_MSG_LINK, "XGXS 8073\n");
 
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
@@ -2089,9 +2092,6 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 					  params->port);
-
-			DP(NETIF_MSG_LINK, "XGXS 8073\n");
-			}
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
@@ -2107,7 +2107,6 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-
 			/* Restore normal power mode*/
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
@@ -2146,20 +2145,18 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 			break;
 
 		default:
-			DP(NETIF_MSG_LINK,
-				 "BAD SerDes ext_phy_config 0x%x\n",
+			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
 				 params->ext_phy_config);
 			break;
 		}
 	}
 }
 
-
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
 				    u32 shmem_base, u32 spirom_ver)
 {
-	DP(NETIF_MSG_LINK, "FW version 0x%x:0x%x\n",
-		 (u16)(spirom_ver>>16), (u16)spirom_ver);
+	DP(NETIF_MSG_LINK, "FW version 0x%x:0x%x for port %d\n",
+		 (u16)(spirom_ver>>16), (u16)spirom_ver, port);
 	REG_WR(bp, shmem_base +
 		   offsetof(struct shmem_region,
 			    port_mb[port].ext_phy_fw_version),
@@ -2171,6 +2168,7 @@ static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp, u8 port,
 				    u32 shmem_base)
 {
 	u16 fw_ver1, fw_ver2;
+
 	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr, MDIO_PMA_DEVAD,
 		      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
 	bnx2x_cl45_read(bp, port, ext_phy_type, ext_phy_addr, MDIO_PMA_DEVAD,
@@ -2423,7 +2421,6 @@ static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 	}
 	DP(NETIF_MSG_LINK, "Warning: XAUI work-around timeout !!!\n");
 	return -EINVAL;
-
 }
 
 static void bnx2x_bcm8073_bcm8727_external_rom_boot(struct bnx2x *bp, u8 port,
@@ -2565,6 +2562,7 @@ static void bnx2x_sfp_set_transmitter(struct bnx2x *bp, u8 port,
 				    u8 tx_en)
 {
 	u16 val;
+
 	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x for port %x\n",
 		 tx_en, port);
 	/* Disable/Enable transmitter ( TX laser of the SFP+ module.)*/
@@ -2597,6 +2595,7 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct link_params *params,
 	u8 port = params->port;
 	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+
 	if (byte_cnt > 16) {
 		DP(NETIF_MSG_LINK, "Reading from eeprom is"
 			    " is limited to 0xf\n");
@@ -2808,6 +2807,7 @@ static u8 bnx2x_get_edc_mode(struct link_params *params,
 	case SFP_EEPROM_CON_TYPE_VAL_COPPER:
 	{
 		u8 copper_module_type;
+
 		/* Check if its active cable( includes SFP+ module)
 		of passive cable*/
 		if (bnx2x_read_sfp_module_eeprom(params,
@@ -2842,7 +2842,6 @@ static u8 bnx2x_get_edc_mode(struct link_params *params,
 		DP(NETIF_MSG_LINK, "Optic module detected\n");
 		check_limiting_mode = 1;
 		break;
-
 	default:
 		DP(NETIF_MSG_LINK, "Unable to determine module type 0x%x !!!\n",
 			 val);
@@ -3169,6 +3168,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 	struct bnx2x *bp = params->bp;
 	u32 gpio_val;
 	u8 port = params->port;
+
 	/* Set valid module led off */
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
 			  MISC_REGISTERS_GPIO_HIGH,
@@ -3236,6 +3236,7 @@ static void bnx2x_bcm807x_force_10G(struct link_params *params)
 		       MDIO_AN_REG_CTRL,
 		       0x0000);
 }
+
 static void bnx2x_bcm8073_set_xaui_low_power_mode(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
@@ -3303,7 +3304,6 @@ static void bnx2x_bcm8073_set_xaui_low_power_mode(struct link_params *params)
 static void bnx2x_8073_set_pause_cl37(struct link_params *params,
 				  struct link_vars *vars)
 {
-
 	struct bnx2x *bp = params->bp;
 	u16 cl37_val;
 	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
@@ -3535,6 +3535,7 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 				  u8 enable_cl73)
 {
 	struct bnx2x *bp = params->bp;
+
 	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
 		if ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
@@ -3585,6 +3586,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 	u16 ctrl = 0;
 	u16 val = 0;
 	u8 rc = 0;
+
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
 		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 
@@ -3881,14 +3883,12 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			bnx2x_8073_set_pause_cl37(params, vars);
 
 			if (ext_phy_type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072){
+			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072)
 				bnx2x_bcm8072_external_rom_boot(params);
-			} else {
-
+			else
 				/* In case of 8073 with long xaui lines,
 				don't set the 8073 xaui low power*/
 				bnx2x_bcm8073_set_xaui_low_power_mode(params);
-			}
 
 			bnx2x_cl45_read(bp, params->port,
 				      ext_phy_type,
@@ -3953,10 +3953,8 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       ext_phy_addr,
 				       MDIO_AN_DEVAD,
 				       MDIO_AN_REG_ADV, val);
-
 			if (ext_phy_type ==
 			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-
 				bnx2x_cl45_read(bp, params->port,
 					      ext_phy_type,
 					      ext_phy_addr,
@@ -4290,7 +4288,6 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			bnx2x_save_spirom_version(params->bp, params->port,
 						params->shmem_base,
 						(u32)(fw_ver1<<16 | fw_ver2));
-
 			break;
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
@@ -4621,6 +4618,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 	u16 rx_sd, pcs_status;
 	u8 ext_phy_link_up = 0;
 	u8 port = params->port;
+
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
 		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
@@ -4729,7 +4727,6 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 						break;
 					}
 				}
-
 				if (val2 & (1<<1))
 					vars->line_speed = SPEED_1000;
 				else
@@ -4786,8 +4783,9 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 
 				if ((val1 & (1<<8)) == 0) {
 					DP(NETIF_MSG_LINK, "8727 Power fault"
-						 " has been detected on port"
-						 " %d\n", params->port);
+						     " has been detected on "
+						     "port %d\n",
+						 params->port);
 					printk(KERN_ERR PFX  "Error:  Power"
 						 " fault on %s Port %d has"
 						 " been detected and the"
@@ -4894,6 +4892,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 		{
 			u16 link_status = 0;
 			u16 an1000_status = 0;
+
 			if (ext_phy_type ==
 			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) {
 				bnx2x_cl45_read(bp, params->port,
@@ -4909,7 +4908,6 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			DP(NETIF_MSG_LINK,
 				 "870x LASI status 0x%x->0x%x\n",
 				  val1, val2);
-
 			} else {
 				/* In 8073, port1 is directed through emac0 and
 				 * port0 is directed through emac1
@@ -5039,8 +5037,6 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 						    MDIO_PMA_DEVAD,
 						    MDIO_PMA_REG_CDR_BANDWIDTH,
 						    0x0333);
-
-
 				}
 				bnx2x_cl45_read(bp, params->port,
 					   ext_phy_type,
@@ -5225,7 +5221,6 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 								 ext_phy_addr);
 				}
 			}
-
 			break;
 		default:
 			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
@@ -5272,6 +5267,7 @@ static void bnx2x_link_int_enable(struct link_params *params)
 	u32 ext_phy_type;
 	u32 mask;
 	struct bnx2x *bp = params->bp;
+
 	/* setting the status to report on link up
 	   for either XGXS or SerDes */
 
@@ -5303,10 +5299,10 @@ static void bnx2x_link_int_enable(struct link_params *params)
 	bnx2x_bits_en(bp,
 		      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
 		      mask);
-	DP(NETIF_MSG_LINK, "port %x, is_xgxs=%x, int_status 0x%x\n", port,
+
+	DP(NETIF_MSG_LINK, "port %x, is_xgxs %x, int_status 0x%x\n", port,
 		 (params->switch_cfg == SWITCH_CFG_10G),
 		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
-
 	DP(NETIF_MSG_LINK, " int_mask 0x%x, MI_INT %x, SERDES_LINK %x\n",
 		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
 		 REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
@@ -5738,6 +5734,7 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 	u8 rc = 0;
 	u32 tmp;
 	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+
 	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
 	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
 		 speed, hw_led_mode);
@@ -5816,6 +5813,7 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	u8 rc = 0;
 	u8 non_ext_phy;
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+
 	/* Activate the external PHY */
 	bnx2x_ext_phy_reset(params, vars);
 
@@ -5889,11 +5887,11 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-
 	u32 val;
-	DP(NETIF_MSG_LINK, "Phy Initialization started \n");
-	DP(NETIF_MSG_LINK, "req_speed = %d, req_flowctrl=%d\n",
-		  params->req_line_speed, params->req_flow_ctrl);
+
+	DP(NETIF_MSG_LINK, "Phy Initialization started\n");
+	DP(NETIF_MSG_LINK, "req_speed %d, req_flowctrl %d\n",
+		 params->req_line_speed, params->req_flow_ctrl);
 	vars->link_status = 0;
 	vars->phy_link_up = 0;
 	vars->link_up = 0;
@@ -5907,7 +5905,6 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	else
 		vars->phy_flags = PHY_XGXS_FLAG;
 
-
 	/* disable attentions */
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
 		       (NIG_MASK_XGXS0_LINK_STATUS |
@@ -5918,6 +5915,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	bnx2x_emac_init(params, vars);
 
 	if (CHIP_REV_IS_FPGA(bp)) {
+
 		vars->link_up = 1;
 		vars->line_speed = SPEED_10000;
 		vars->duplex = DUPLEX_FULL;
@@ -5926,7 +5924,8 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		/* enable on E1.5 FPGA */
 		if (CHIP_IS_E1H(bp)) {
 			vars->flow_ctrl |=
-				(BNX2X_FLOW_CTRL_TX | BNX2X_FLOW_CTRL_RX);
+					(BNX2X_FLOW_CTRL_TX |
+					 BNX2X_FLOW_CTRL_RX);
 			vars->link_status |=
 					(LINK_STATUS_TX_FLOW_CONTROL_ENABLED |
 					 LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
@@ -5935,8 +5934,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		bnx2x_emac_enable(params, vars, 0);
 		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
 		/* disable drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
-				    + params->port*4, 0);
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 
 		/* update shared memory */
 		bnx2x_update_mng(params, vars->link_status);
@@ -5966,6 +5964,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 	} else
 	if (params->loopback_mode == LOOPBACK_BMAC) {
+
 		vars->link_up = 1;
 		vars->line_speed = SPEED_10000;
 		vars->duplex = DUPLEX_FULL;
@@ -5980,7 +5979,9 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 		    params->port*4, 0);
+
 	} else if (params->loopback_mode == LOOPBACK_EMAC) {
+
 		vars->link_up = 1;
 		vars->line_speed = SPEED_1000;
 		vars->duplex = DUPLEX_FULL;
@@ -5996,8 +5997,10 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 					      vars->duplex);
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 		    params->port*4, 0);
+
 	} else if ((params->loopback_mode == LOOPBACK_XGXS_10) ||
-		  (params->loopback_mode == LOOPBACK_EXT_PHY)) {
+		   (params->loopback_mode == LOOPBACK_EXT_PHY)) {
+
 		vars->link_up = 1;
 		vars->line_speed = SPEED_10000;
 		vars->duplex = DUPLEX_FULL;
@@ -6034,7 +6037,6 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	} else
 	/* No loopback */
 	{
-
 		bnx2x_phy_deassert(params, vars->phy_flags);
 		switch (params->switch_cfg) {
 		case SWITCH_CFG_1G:
@@ -6042,8 +6044,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 			if ((params->ext_phy_config &
 			     PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK) ==
 			     PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482) {
-				vars->phy_flags |=
-					PHY_SGMII_FLAG;
+				vars->phy_flags |= PHY_SGMII_FLAG;
 			}
 
 			val = REG_RD(bp,
@@ -6064,7 +6065,6 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		default:
 			DP(NETIF_MSG_LINK, "Invalid switch_cfg\n");
 			return -EINVAL;
-			break;
 		}
 		DP(NETIF_MSG_LINK, "Phy address = 0x%x\n", params->phy_addr);
 
@@ -6089,7 +6089,6 @@ static void bnx2x_8726_reset_phy(struct bnx2x *bp, u8 port, u8 ext_phy_addr)
 u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		  u8 reset_ext_phy)
 {
-
 	struct bnx2x *bp = params->bp;
 	u32 ext_phy_config = params->ext_phy_config;
 	u16 hw_led_mode = params->hw_led_mode;
@@ -6102,7 +6101,6 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 				      config));
 
 	/* disable attentions */
-
 	vars->link_status = 0;
 	bnx2x_update_mng(params, vars->link_status);
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
@@ -6198,6 +6196,7 @@ static u8 bnx2x_update_link_down(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
+
 	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
 	bnx2x_set_led(bp, port, LED_MODE_OFF,
 		    0, params->hw_led_mode,
@@ -6234,6 +6233,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
 	u8 rc = 0;
+
 	vars->link_status |= LINK_STATUS_LINK_UP;
 	if (link_10g) {
 		bnx2x_bmac_enable(params, vars, 0);
@@ -6547,6 +6547,7 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	u8 ext_phy_addr;
 	u32 val;
 	s8 port;
+
 	/* Use port1 because of the static port-swap */
 	/* Enable the module detection interrupt */
 	val = REG_RD(bp, MISC_REG_GPIO_EVENT_EN);
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index c4c0f97..54e3ef9 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -63,8 +63,8 @@
 #include <linux/firmware.h>
 #include "bnx2x_fw_file_hdr.h"
 /* FW files */
-#define FW_FILE_PREFIX_E1		"bnx2x-e1-"
-#define FW_FILE_PREFIX_E1H		"bnx2x-e1h-"
+#define FW_FILE_PREFIX_E1	"bnx2x-e1-"
+#define FW_FILE_PREFIX_E1H	"bnx2x-e1h-"
 
 /* Time in jiffies before concluding the transmitter is hung */
 #define TX_TIMEOUT		(5*HZ)
@@ -722,7 +722,6 @@ static void bnx2x_int_disable(struct bnx2x *bp)
 	REG_WR(bp, addr, val);
 	if (REG_RD(bp, addr) != val)
 		BNX2X_ERR("BUG! proper val not read from IGU!\n");
-
 }
 
 static void bnx2x_int_disable_sync(struct bnx2x *bp, int disable_hw)
@@ -1659,6 +1658,7 @@ reuse_rx:
 		}
 
 		skb_record_rx_queue(skb, fp->index);
+
 #ifdef BCM_VLAN
 		if ((bp->vlgrp != NULL) && (bp->flags & HW_VLAN_RX_FLAG) &&
 		    (le16_to_cpu(cqe->fast_path_cqe.pars_flags.flags) &
@@ -2417,14 +2417,12 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 		int func;
 		int vn;
 
+		/* Set the attention towards other drivers on the same port */
 		for (vn = VN_0; vn < E1HVN_MAX; vn++) {
 			if (vn == BP_E1HVN(bp))
 				continue;
 
 			func = ((vn << 1) | port);
-
-			/* Set the attention towards other drivers
-			   on the same port */
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
 			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
 		}
@@ -2879,6 +2877,7 @@ static inline void bnx2x_fan_failure(struct bnx2x *bp)
 	       " damage.  Please contact Dell Support for assistance\n",
 	       bp->dev->name);
 }
+
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 {
 	int port = BP_PORT(bp);
@@ -7659,9 +7658,11 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 
 	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
 
+	/* Set "drop all" */
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 	bnx2x_set_storm_rx_mode(bp);
 
+	/* Disable HW interrupts, NAPI and Tx */
 	bnx2x_netif_stop(bp, 1);
 
 	del_timer_sync(&bp->timer);
@@ -9157,8 +9158,7 @@ static int bnx2x_nway_reset(struct net_device *dev)
 	return 0;
 }
 
-static u32
-bnx2x_get_link(struct net_device *dev)
+static u32 bnx2x_get_link(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
@@ -10168,7 +10168,7 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 	__be32 buf[0x350 / 4];
 	u8 *data = (u8 *)buf;
 	int i, rc;
-	u32 magic, csum;
+	u32 magic, crc;
 
 	rc = bnx2x_nvram_read(bp, 0, data, 4);
 	if (rc) {
@@ -10193,10 +10193,10 @@ static int bnx2x_test_nvram(struct bnx2x *bp)
 			goto test_nvram_exit;
 		}
 
-		csum = ether_crc_le(nvram_tbl[i].size, data);
-		if (csum != CRC32_RESIDUAL) {
+		crc = ether_crc_le(nvram_tbl[i].size, data);
+		if (crc != CRC32_RESIDUAL) {
 			DP(NETIF_MSG_PROBE,
-			   "nvram_tbl[%d] csum value (0x%08x)\n", i, csum);
+			   "nvram_tbl[%d] crc value (0x%08x)\n", i, crc);
 			rc = -ENODEV;
 			goto test_nvram_exit;
 		}
@@ -11770,17 +11770,17 @@ static int __devinit bnx2x_check_firmware(struct bnx2x *bp)
 		       BCM_5710_FW_MINOR_VERSION,
 		       BCM_5710_FW_REVISION_VERSION,
 		       BCM_5710_FW_ENGINEERING_VERSION);
-                return -EINVAL;
+		return -EINVAL;
 	}
 
 	return 0;
 }
 
-static void inline be32_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
+static inline void be32_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 {
+	const __be32 *source = (const __be32 *)_source;
+	u32 *target = (u32 *)_target;
 	u32 i;
-	const __be32 *source = (const __be32*)_source;
-	u32 *target = (u32*)_target;
 
 	for (i = 0; i < n/4; i++)
 		target[i] = be32_to_cpu(source[i]);
@@ -11790,66 +11790,67 @@ static void inline be32_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
    Ops array is stored in the following format:
    {op(8bit), offset(24bit, big endian), data(32bit, big endian)}
  */
-static void inline bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 n)
+static inline void bnx2x_prep_ops(const u8 *_source, u8 *_target, u32 n)
 {
+	const __be32 *source = (const __be32 *)_source;
+	struct raw_op *target = (struct raw_op *)_target;
 	u32 i, j, tmp;
-	const __be32 *source = (const __be32*)_source;
-	struct raw_op *target = (struct raw_op*)_target;
 
-	for (i = 0, j = 0; i < n/8; i++, j+=2) {
+	for (i = 0, j = 0; i < n/8; i++, j += 2) {
 		tmp = be32_to_cpu(source[j]);
 		target[i].op = (tmp >> 24) & 0xff;
 		target[i].offset =  tmp & 0xffffff;
 		target[i].raw_data = be32_to_cpu(source[j+1]);
 	}
 }
-static void inline be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
+
+static inline void be16_to_cpu_n(const u8 *_source, u8 *_target, u32 n)
 {
+	const __be16 *source = (const __be16 *)_source;
+	u16 *target = (u16 *)_target;
 	u32 i;
-	u16 *target = (u16*)_target;
-	const __be16 *source = (const __be16*)_source;
 
 	for (i = 0; i < n/2; i++)
 		target[i] = be16_to_cpu(source[i]);
 }
 
 #define BNX2X_ALLOC_AND_SET(arr, lbl, func) \
-	do {   \
-		u32 len = be32_to_cpu(fw_hdr->arr.len);   \
-		bp->arr = kmalloc(len, GFP_KERNEL);  \
+	do { \
+		u32 len = be32_to_cpu(fw_hdr->arr.len); \
+		bp->arr = kmalloc(len, GFP_KERNEL); \
 		if (!bp->arr) { \
-			printk(KERN_ERR PFX "Failed to allocate %d bytes for "#arr"\n", len); \
+			printk(KERN_ERR PFX "Failed to allocate %d bytes " \
+					    "for "#arr"\n", len); \
 			goto lbl; \
 		} \
-		func(bp->firmware->data + \
-			be32_to_cpu(fw_hdr->arr.offset), \
-			(u8*)bp->arr, len); \
+		func(bp->firmware->data + be32_to_cpu(fw_hdr->arr.offset), \
+		     (u8 *)bp->arr, len); \
 	} while (0)
 
-
 static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 {
 	char fw_file_name[40] = {0};
-        int rc, offset;
 	struct bnx2x_fw_file_hdr *fw_hdr;
+	int rc, offset;
 
 	/* Create a FW file name */
 	if (CHIP_IS_E1(bp))
-                offset = sprintf(fw_file_name, FW_FILE_PREFIX_E1);
+		offset = sprintf(fw_file_name, FW_FILE_PREFIX_E1);
 	else
 		offset = sprintf(fw_file_name, FW_FILE_PREFIX_E1H);
 
 	sprintf(fw_file_name + offset, "%d.%d.%d.%d.fw",
 		BCM_5710_FW_MAJOR_VERSION,
-                BCM_5710_FW_MINOR_VERSION,
-                BCM_5710_FW_REVISION_VERSION,
-                BCM_5710_FW_ENGINEERING_VERSION);
+		BCM_5710_FW_MINOR_VERSION,
+		BCM_5710_FW_REVISION_VERSION,
+		BCM_5710_FW_ENGINEERING_VERSION);
 
 	printk(KERN_INFO PFX "Loading %s\n", fw_file_name);
 
 	rc = request_firmware(&bp->firmware, fw_file_name, dev);
 	if (rc) {
-		printk(KERN_ERR PFX "Can't load firmware file %s\n", fw_file_name);
+		printk(KERN_ERR PFX "Can't load firmware file %s\n",
+		       fw_file_name);
 		goto request_firmware_exit;
 	}
 
@@ -11869,7 +11870,8 @@ static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 	BNX2X_ALLOC_AND_SET(init_ops, init_ops_alloc_err, bnx2x_prep_ops);
 
 	/* Offsets */
-	BNX2X_ALLOC_AND_SET(init_ops_offsets, init_offsets_alloc_err, be16_to_cpu_n);
+	BNX2X_ALLOC_AND_SET(init_ops_offsets, init_offsets_alloc_err,
+			    be16_to_cpu_n);
 
 	/* STORMs firmware */
 	INIT_TSEM_INT_TABLE_DATA(bp) = bp->firmware->data +
@@ -11890,6 +11892,7 @@ static int __devinit bnx2x_init_firmware(struct bnx2x *bp, struct device *dev)
 			be32_to_cpu(fw_hdr->csem_pram_data.offset);
 
 	return 0;
+
 init_offsets_alloc_err:
 	kfree(bp->init_ops);
 init_ops_alloc_err:
@@ -11901,7 +11904,6 @@ request_firmware_exit:
 }
 
 
-
 static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
 {
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 95ebf3f..0695be1 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -4561,7 +4561,8 @@
 #define LATCHED_ATTN_SCPAD_PARITY_MCP		33
 
 #define GENERAL_ATTEN_WORD(atten_name)	       ((94 + atten_name) / 32)
-#define GENERAL_ATTEN_OFFSET(atten_name)       (1 << ((94 + atten_name) % 32))
+#define GENERAL_ATTEN_OFFSET(atten_name)\
+	(1UL << ((94 + atten_name) % 32))
 /*
  * This file defines GRC base address for every block.
  * This file is included by chipsim, asm microcode and cpp microcode.
-- 
1.5.4.3




