From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 01/10] chelsio: whitespace fixes
Date: Fri, 01 Dec 2006 16:36:13 -0800
Message-ID: <20061202003707.203984000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:35554 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162401AbWLBAjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:39:19 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=whitespace.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix indentation and blank/tab issues.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/chelsio/cxgb2.c  |    2 +-
 drivers/net/chelsio/espi.c   |    2 +-
 drivers/net/chelsio/pm3393.c |   16 ++++++++--------
 drivers/net/chelsio/subr.c   |   12 ++++++------
 4 files changed, 16 insertions(+), 16 deletions(-)

--- chelsio.orig/drivers/net/chelsio/cxgb2.c
+++ chelsio/drivers/net/chelsio/cxgb2.c
@@ -729,7 +729,7 @@ static int get_coalesce(struct net_devic
 
 static int get_eeprom_len(struct net_device *dev)
 {
-    return EEPROM_SIZE;
+	return EEPROM_SIZE;
 }
 
 #define EEPROM_MAGIC(ap) \
--- chelsio.orig/drivers/net/chelsio/espi.c
+++ chelsio/drivers/net/chelsio/espi.c
@@ -192,7 +192,7 @@ int t1_espi_intr_handler(struct peespi *
 
 const struct espi_intr_counts *t1_espi_get_intr_counts(struct peespi *espi)
 {
-    return &espi->intr_cnt;
+	return &espi->intr_cnt;
 }
 
 static void espi_setup_for_pm3393(adapter_t *adapter)
--- chelsio.orig/drivers/net/chelsio/pm3393.c
+++ chelsio/drivers/net/chelsio/pm3393.c
@@ -46,17 +46,17 @@
 /* 802.3ae 10Gb/s MDIO Manageable Device(MMD)
  */
 enum {
-    MMD_RESERVED,
-    MMD_PMAPMD,
-    MMD_WIS,
-    MMD_PCS,
-    MMD_PHY_XGXS,	/* XGMII Extender Sublayer */
-    MMD_DTE_XGXS,
+	MMD_RESERVED,
+	MMD_PMAPMD,
+	MMD_WIS,
+	MMD_PCS,
+	MMD_PHY_XGXS,	/* XGMII Extender Sublayer */
+	MMD_DTE_XGXS,
 };
 
 enum {
-    PHY_XGXS_CTRL_1,
-    PHY_XGXS_STATUS_1
+	PHY_XGXS_CTRL_1,
+	PHY_XGXS_STATUS_1
 };
 
 #define OFFSET(REG_ADDR)    (REG_ADDR << 2)
--- chelsio.orig/drivers/net/chelsio/subr.c
+++ chelsio/drivers/net/chelsio/subr.c
@@ -166,11 +166,11 @@ static int t1_pci_intr_handler(adapter_t
 {
 	u32 pcix_cause;
 
-    	pci_read_config_dword(adapter->pdev, A_PCICFG_INTR_CAUSE, &pcix_cause);
+	pci_read_config_dword(adapter->pdev, A_PCICFG_INTR_CAUSE, &pcix_cause);
 
 	if (pcix_cause) {
 		pci_write_config_dword(adapter->pdev, A_PCICFG_INTR_CAUSE,
-					 pcix_cause);
+				       pcix_cause);
 		t1_fatal_err(adapter);    /* PCI errors are fatal */
 	}
 	return 0;
@@ -420,9 +420,9 @@ int t1_link_start(struct cphy *phy, stru
  */
 int elmer0_ext_intr_handler(adapter_t *adapter)
 {
-    	struct cphy *phy;
+	struct cphy *phy;
 	int phy_cause;
-    	u32 cause;
+	u32 cause;
 
 	t1_tpi_read(adapter, A_ELMER0_INT_CAUSE, &cause);
 
@@ -515,7 +515,7 @@ void t1_interrupts_clear(adapter_t* adap
 	}
 
 	/* Enable interrupts for external devices. */
-    	pl_intr = readl(adapter->regs + A_PL_CAUSE);
+	pl_intr = readl(adapter->regs + A_PL_CAUSE);
 
 	writel(pl_intr | F_PL_INTR_EXT | F_PL_INTR_PCIX,
 	       adapter->regs + A_PL_CAUSE);
@@ -643,7 +643,7 @@ static int board_init(adapter_t *adapter
 	case CHBT_BOARD_N110:
 	case CHBT_BOARD_N210:
 		writel(V_TPIPAR(0xf), adapter->regs + A_TPI_PAR);
-    		t1_tpi_write(adapter, A_ELMER0_GPO, 0x800);
+		t1_tpi_write(adapter, A_ELMER0_GPO, 0x800);
 		break;
 	}
 	return 0;

-- 

