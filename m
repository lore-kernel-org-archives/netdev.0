From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: ethernet: freescale: fs_enet: make mdiobb_ops const
Date: Tue, 22 Aug 2017 13:45:59 +0530
Message-ID: <1503389759-17545-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, pantelis.antoniou@gmail.com,
        vbordug@ru.mvista.com, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make this const as it is only stored in a const field of a
mdiobb_ctrl structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
index 1f015ed..c8e5d88 100644
--- a/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
+++ b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
@@ -100,7 +100,7 @@ static inline void mdc(struct mdiobb_ctrl *ctrl, int what)
 	in_be32(bitbang->dat);
 }
 
-static struct mdiobb_ops bb_ops = {
+static const struct mdiobb_ops bb_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = mdc,
 	.set_mdio_dir = mdio_dir,
-- 
1.9.1
