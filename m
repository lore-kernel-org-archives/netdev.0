From: Valentin Longchamp <valentin.longchamp@keymile.com>
Subject: [PATCH] net/ethernet/freescale: fix warning for ucc_geth
Date: Thu, 14 Sep 2017 14:05:14 +0200
Message-ID: <20170914120514.31845-1-valentin.longchamp@keymile.com>
Cc: linuxppc-dev@lists.ozlabs.org,
        Valentin Longchamp <valentin.longchamp@keymile.com>
To: leoli@freescale.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-de.keymile.com ([195.8.104.250]:50751 "EHLO
        mail-de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdINMLB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 08:11:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple printk format warning for the the ucc registers address.

Signed-off-by: Valentin Longchamp <valentin.longchamp@keymile.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index f77ba9fa257b..56b8fdb35c3b 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3857,7 +3857,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	}
 
 	if (netif_msg_probe(&debug))
-		pr_info("UCC%1d at 0x%8x (irq = %d)\n",
+		pr_info("UCC%1d at 0x%8llx (irq = %d)\n",
 			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
 			ug_info->uf_info.irq);
 
-- 
2.13.5
