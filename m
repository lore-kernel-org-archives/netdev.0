From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: ethernet: ax88796: make mdiobb_ops const
Date: Tue, 22 Aug 2017 13:41:19 +0530
Message-ID: <1503389479-17429-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make this const as it is only stored in a const field of a
mdiobb_ctrl structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/8390/ax88796.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/8390/ax88796.c b/drivers/net/ethernet/8390/ax88796.c
index 05d9d3e..2455547 100644
--- a/drivers/net/ethernet/8390/ax88796.c
+++ b/drivers/net/ethernet/8390/ax88796.c
@@ -585,7 +585,7 @@ static int ax_bb_get_data(struct mdiobb_ctrl *ctrl)
 	return reg_memr & AX_MEMR_MDI ? 1 : 0;
 }
 
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = ax_bb_mdc,
 	.set_mdio_dir = ax_bb_dir,
-- 
1.9.1
