From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] ravb: make mdiobb_ops const
Date: Tue, 22 Aug 2017 13:38:02 +0530
Message-ID: <1503389282-17369-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, sergei.shtylyov@cogentembedded.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are only stored in a const field of a
mdiobb_ctrl structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/renesas/ravb_main.c | 2 +-
 drivers/net/ethernet/renesas/sh_eth.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index fdf30bf..6ffd9e4 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -172,7 +172,7 @@ static int ravb_get_mdio_data(struct mdiobb_ctrl *ctrl)
 }
 
 /* MDIO bus control struct */
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = ravb_set_mdc,
 	.set_mdio_dir = ravb_set_mdio_dir,
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index d2e88a3..8af353f 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -1119,7 +1119,7 @@ static void sh_mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
 }
 
 /* mdio bus control struct */
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = sh_mdc_ctrl,
 	.set_mdio_dir = sh_mmd_ctrl,
-- 
1.9.1
