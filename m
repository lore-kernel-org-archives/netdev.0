From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] qlcnic: constify qlcnic_dcb_ops structures
Date: Sun, 27 Dec 2015 22:01:29 +0100
Message-ID: <1451250089-6989-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Dept-GELinuxNICDev@qlogic.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The qlcnic_dcb_ops structures are never modified, so declare them as const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
index a72bcdd..4b76c69 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.c
@@ -167,7 +167,7 @@ struct qlcnic_dcb_cfg {
 	u32 version;
 };
 
-static struct qlcnic_dcb_ops qlcnic_83xx_dcb_ops = {
+static const struct qlcnic_dcb_ops qlcnic_83xx_dcb_ops = {
 	.init_dcbnl_ops		= __qlcnic_init_dcbnl_ops,
 	.free			= __qlcnic_dcb_free,
 	.attach			= __qlcnic_dcb_attach,
@@ -180,7 +180,7 @@ static struct qlcnic_dcb_ops qlcnic_83xx_dcb_ops = {
 	.aen_handler		= qlcnic_83xx_dcb_aen_handler,
 };
 
-static struct qlcnic_dcb_ops qlcnic_82xx_dcb_ops = {
+static const struct qlcnic_dcb_ops qlcnic_82xx_dcb_ops = {
 	.init_dcbnl_ops		= __qlcnic_init_dcbnl_ops,
 	.free			= __qlcnic_dcb_free,
 	.attach			= __qlcnic_dcb_attach,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
index 3cf4a10..9777e57 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_dcb.h
@@ -37,7 +37,7 @@ struct qlcnic_dcb {
 	struct qlcnic_adapter		*adapter;
 	struct delayed_work		aen_work;
 	struct workqueue_struct		*wq;
-	struct qlcnic_dcb_ops		*ops;
+	const struct qlcnic_dcb_ops	*ops;
 	struct qlcnic_dcb_cfg		*cfg;
 	unsigned long			state;
 };

