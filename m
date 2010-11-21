From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/62] cxgb3: Use static const
Date: Sat, 20 Nov 2010 18:38:12 -0800
Message-ID: <c76c0a62288f3d7f55bf877db065e4a67ac06737.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   8401	    368	   2008	  10777	   2a19	drivers/net/cxgb3/ael1002.o.new
   8129	    680	   2008	  10817	   2a41	drivers/net/cxgb3/ael1002.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/cxgb3/ael1002.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 35cd367..2028da9 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -292,7 +292,7 @@ unknown:
  */
 static int ael2005_setup_sr_edc(struct cphy *phy)
 {
-	static struct reg_val regs[] = {
+	static const struct reg_val regs[] = {
 		{ MDIO_MMD_PMAPMD, 0xc003, 0xffff, 0x181 },
 		{ MDIO_MMD_PMAPMD, 0xc010, 0xffff, 0x448a },
 		{ MDIO_MMD_PMAPMD, 0xc04a, 0xffff, 0x5200 },
@@ -324,11 +324,11 @@ static int ael2005_setup_sr_edc(struct cphy *phy)
 
 static int ael2005_setup_twinax_edc(struct cphy *phy, int modtype)
 {
-	static struct reg_val regs[] = {
+	static const struct reg_val regs[] = {
 		{ MDIO_MMD_PMAPMD, 0xc04a, 0xffff, 0x5a00 },
 		{ 0, 0, 0, 0 }
 	};
-	static struct reg_val preemphasis[] = {
+	static const struct reg_val preemphasis[] = {
 		{ MDIO_MMD_PMAPMD, 0xc014, 0xffff, 0xfe16 },
 		{ MDIO_MMD_PMAPMD, 0xc015, 0xffff, 0xa000 },
 		{ 0, 0, 0, 0 }
@@ -393,7 +393,7 @@ static int ael2005_intr_clear(struct cphy *phy)
 
 static int ael2005_reset(struct cphy *phy, int wait)
 {
-	static struct reg_val regs0[] = {
+	static const struct reg_val regs0[] = {
 		{ MDIO_MMD_PMAPMD, 0xc001, 0, 1 << 5 },
 		{ MDIO_MMD_PMAPMD, 0xc017, 0, 1 << 5 },
 		{ MDIO_MMD_PMAPMD, 0xc013, 0xffff, 0xf341 },
@@ -403,7 +403,7 @@ static int ael2005_reset(struct cphy *phy, int wait)
 		{ MDIO_MMD_PMAPMD, 0xc210, 0xffff, 0 },
 		{ 0, 0, 0, 0 }
 	};
-	static struct reg_val regs1[] = {
+	static const struct reg_val regs1[] = {
 		{ MDIO_MMD_PMAPMD, 0xca00, 0xffff, 0x0080 },
 		{ MDIO_MMD_PMAPMD, 0xca12, 0xffff, 0 },
 		{ 0, 0, 0, 0 }
@@ -522,7 +522,7 @@ int t3_ael2005_phy_prep(struct cphy *phy, struct adapter *adapter,
  */
 static int ael2020_setup_sr_edc(struct cphy *phy)
 {
-	static struct reg_val regs[] = {
+	static const struct reg_val regs[] = {
 		/* set CDR offset to 10 */
 		{ MDIO_MMD_PMAPMD, 0xcc01, 0xffff, 0x488a },
 
@@ -551,20 +551,20 @@ static int ael2020_setup_sr_edc(struct cphy *phy)
 static int ael2020_setup_twinax_edc(struct cphy *phy, int modtype)
 {
 	/* set uC to 40MHz */
-	static struct reg_val uCclock40MHz[] = {
+	static const struct reg_val uCclock40MHz[] = {
 		{ MDIO_MMD_PMAPMD, 0xff28, 0xffff, 0x4001 },
 		{ MDIO_MMD_PMAPMD, 0xff2a, 0xffff, 0x0002 },
 		{ 0, 0, 0, 0 }
 	};
 
 	/* activate uC clock */
-	static struct reg_val uCclockActivate[] = {
+	static const struct reg_val uCclockActivate[] = {
 		{ MDIO_MMD_PMAPMD, 0xd000, 0xffff, 0x5200 },
 		{ 0, 0, 0, 0 }
 	};
 
 	/* set PC to start of SRAM and activate uC */
-	static struct reg_val uCactivate[] = {
+	static const struct reg_val uCactivate[] = {
 		{ MDIO_MMD_PMAPMD, 0xd080, 0xffff, 0x0100 },
 		{ MDIO_MMD_PMAPMD, 0xd092, 0xffff, 0x0000 },
 		{ 0, 0, 0, 0 }
@@ -624,7 +624,7 @@ static int ael2020_get_module_type(struct cphy *phy, int delay_ms)
  */
 static int ael2020_intr_enable(struct cphy *phy)
 {
-	struct reg_val regs[] = {
+	static const struct reg_val regs[] = {
 		/* output Module's Loss Of Signal (LOS) to LED */
 		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CFG+AEL2020_GPIO_LSTAT,
 			0xffff, 0x4 },
@@ -664,7 +664,7 @@ static int ael2020_intr_enable(struct cphy *phy)
  */
 static int ael2020_intr_disable(struct cphy *phy)
 {
-	struct reg_val regs[] = {
+	static const struct reg_val regs[] = {
 		/* reset "link status" LED to "off" */
 		{ MDIO_MMD_PMAPMD, AEL2020_GPIO_CTRL,
 			0xffff, 0xb << (AEL2020_GPIO_LSTAT*4) },
@@ -701,7 +701,7 @@ static int ael2020_intr_clear(struct cphy *phy)
 	return err ? err : t3_phy_lasi_intr_clear(phy);
 }
 
-static struct reg_val ael2020_reset_regs[] = {
+static const struct reg_val ael2020_reset_regs[] = {
 	/* Erratum #2: CDRLOL asserted, causing PMA link down status */
 	{ MDIO_MMD_PMAPMD, 0xc003, 0xffff, 0x3101 },
 
-- 
1.7.3.2.245.g03276.dirty
