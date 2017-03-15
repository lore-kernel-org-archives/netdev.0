From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/7] drivers: net: phy: xgene: Fix mdio write
Date: Wed, 15 Mar 2017 13:27:15 -0700
Message-ID: <1489609641-31557-2-git-send-email-isubramanian@apm.com>
References: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34563 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751867AbdCOU0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:06 -0400
Received: by mail-pg0-f42.google.com with SMTP id 141so14095309pgd.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:05 -0700 (PDT)
In-Reply-To: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patches fixes a typo in the argument to xgene_enet_wr_mdio_csr().

Signed-off-by: Quan Nguyen <qnguyen@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/phy/mdio-xgene.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-xgene.c b/drivers/net/phy/mdio-xgene.c
index f095051..3e2ac07 100644
--- a/drivers/net/phy/mdio-xgene.c
+++ b/drivers/net/phy/mdio-xgene.c
@@ -229,7 +229,7 @@ static int xgene_xfi_mdio_write(struct mii_bus *bus, int phy_id,
 
 	val = SET_VAL(HSTPHYADX, phy_id) | SET_VAL(HSTREGADX, reg) |
 	      SET_VAL(HSTMIIMWRDAT, data);
-	xgene_enet_wr_mdio_csr(addr, MIIM_FIELD_ADDR, data);
+	xgene_enet_wr_mdio_csr(addr, MIIM_FIELD_ADDR, val);
 
 	val = HSTLDCMD | SET_VAL(HSTMIIMCMD, MIIM_CMD_LEGACY_WRITE);
 	xgene_enet_wr_mdio_csr(addr, MIIM_COMMAND_ADDR, val);
-- 
1.9.1
