From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH 18/38] net/ibm/emac: fix type of phy_mode
Date: Mon, 21 Sep 2015 15:33:50 +0200
Message-ID: <1442842450-29769-19-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Ivan Mikhaylov <ivan@ru.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

phy_mode can be negative.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2038576

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
 drivers/net/ethernet/ibm/emac/core.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.h b/drivers/net/ethernet/ibm/emac/core.h
index 28df374..f379e47 100644
--- a/drivers/net/ethernet/ibm/emac/core.h
+++ b/drivers/net/ethernet/ibm/emac/core.h
@@ -181,7 +181,7 @@ struct emac_instance {
 	struct mal_commac		commac;
 
 	/* PHY infos */
-	u32				phy_mode;
+	int				phy_mode;
 	u32				phy_map;
 	u32				phy_address;
 	u32				phy_feat_exc;
-- 
1.9.1
