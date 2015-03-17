From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 03/16 linux-next] net/fsl: constify of_device_id array
Date: Tue, 17 Mar 2015 19:37:34 +0100
Message-ID: <1426617469-781-4-git-send-email-fabf@skynet.be>
References: <1426617469-781-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426617469-781-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

of_device_id is always used as const.
(See driver.of_match_table and open firmware functions)

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/freescale/fec_mpc52xx.c          | 2 +-
 drivers/net/ethernet/freescale/fec_mpc52xx_phy.c      | 2 +-
 drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 4 ++--
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c  | 2 +-
 drivers/net/ethernet/freescale/fs_enet/mii-fec.c      | 4 ++--
 drivers/net/ethernet/freescale/fsl_pq_mdio.c          | 2 +-
 drivers/net/ethernet/freescale/gianfar.c              | 2 +-
 drivers/net/ethernet/freescale/gianfar_ptp.c          | 2 +-
 drivers/net/ethernet/freescale/ucc_geth.c             | 2 +-
 drivers/net/ethernet/freescale/xgmac_mdio.c           | 2 +-
 10 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index f495796..afe7f39 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -1057,7 +1057,7 @@ static int mpc52xx_fec_of_resume(struct platform_device *op)
 }
 #endif
 
-static struct of_device_id mpc52xx_fec_match[] = {
+static const struct of_device_id mpc52xx_fec_match[] = {
 	{ .compatible = "fsl,mpc5200b-fec", },
 	{ .compatible = "fsl,mpc5200-fec", },
 	{ .compatible = "mpc5200-fec", },
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
index e052890..1e647be 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
@@ -134,7 +134,7 @@ static int mpc52xx_fec_mdio_remove(struct platform_device *of)
 	return 0;
 }
 
-static struct of_device_id mpc52xx_fec_mdio_match[] = {
+static const struct of_device_id mpc52xx_fec_mdio_match[] = {
 	{ .compatible = "fsl,mpc5200b-mdio", },
 	{ .compatible = "fsl,mpc5200-mdio", },
 	{ .compatible = "mpc5200b-fec-phy", },
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index a176287..9b3639e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -916,7 +916,7 @@ static const struct net_device_ops fs_enet_netdev_ops = {
 #endif
 };
 
-static struct of_device_id fs_enet_match[];
+static const struct of_device_id fs_enet_match[];
 static int fs_enet_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
@@ -1082,7 +1082,7 @@ static int fs_enet_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id fs_enet_match[] = {
+static const struct of_device_id fs_enet_match[] = {
 #ifdef CONFIG_FS_ENET_HAS_SCC
 	{
 		.compatible = "fsl,cpm1-scc-enet",
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 1d5617d..68a428d 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -213,7 +213,7 @@ static int fs_enet_mdio_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id fs_enet_mdio_bb_match[] = {
+static const struct of_device_id fs_enet_mdio_bb_match[] = {
 	{
 		.compatible = "fsl,cpm2-mdio-bitbang",
 	},
diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
index 1648e35..2be383e 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
@@ -95,7 +95,7 @@ static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int location,
 
 }
 
-static struct of_device_id fs_enet_mdio_fec_match[];
+static const struct of_device_id fs_enet_mdio_fec_match[];
 static int fs_enet_mdio_probe(struct platform_device *ofdev)
 {
 	const struct of_device_id *match;
@@ -208,7 +208,7 @@ static int fs_enet_mdio_remove(struct platform_device *ofdev)
 	return 0;
 }
 
-static struct of_device_id fs_enet_mdio_fec_match[] = {
+static const struct of_device_id fs_enet_mdio_fec_match[] = {
 	{
 		.compatible = "fsl,pq1-fec-mdio",
 	},
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index d1a91e3..3c40f6b 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -294,7 +294,7 @@ static void ucc_configure(phys_addr_t start, phys_addr_t end)
 
 #endif
 
-static struct of_device_id fsl_pq_mdio_match[] = {
+static const struct of_device_id fsl_pq_mdio_match[] = {
 #if defined(CONFIG_GIANFAR) || defined(CONFIG_GIANFAR_MODULE)
 	{
 		.compatible = "fsl,gianfar-tbi",
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 70fa688..4ee080d 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3594,7 +3594,7 @@ static noinline void gfar_update_link_state(struct gfar_private *priv)
 		phy_print_status(phydev);
 }
 
-static struct of_device_id gfar_match[] =
+static const struct of_device_id gfar_match[] =
 {
 	{
 		.type = "network",
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 1682634..77353366 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -554,7 +554,7 @@ static int gianfar_ptp_remove(struct platform_device *dev)
 	return 0;
 }
 
-static struct of_device_id match_table[] = {
+static const struct of_device_id match_table[] = {
 	{ .compatible = "fsl,etsec-ptp" },
 	{},
 };
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 357e8b57..bfdccbd 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3930,7 +3930,7 @@ static int ucc_geth_remove(struct platform_device* ofdev)
 	return 0;
 }
 
-static struct of_device_id ucc_geth_match[] = {
+static const struct of_device_id ucc_geth_match[] = {
 	{
 		.type = "network",
 		.compatible = "ucc_geth",
diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c b/drivers/net/ethernet/freescale/xgmac_mdio.c
index cd40b68..7b8fe86 100644
--- a/drivers/net/ethernet/freescale/xgmac_mdio.c
+++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
@@ -307,7 +307,7 @@ static int xgmac_mdio_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static struct of_device_id xgmac_mdio_match[] = {
+static const struct of_device_id xgmac_mdio_match[] = {
 	{
 		.compatible = "fsl,fman-xmdio",
 	},
-- 
2.1.0
