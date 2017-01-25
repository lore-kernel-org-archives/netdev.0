From: John Crispin <john@phrozen.org>
Subject: [PATCH 2/2] net-next: ethernet: mediatek: change the compatible string
Date: Wed, 25 Jan 2017 09:20:55 +0100
Message-ID: <1485332455-34743-2-git-send-email-john@phrozen.org>
References: <1485332455-34743-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, Sean Wang <sean.wang@mediatek.com>,
        devicetree@vger.kernel.org, linux-mediatek@lists.infradead.org,
        John Crispin <john@phrozen.org>
To: Rob Herring <robh+dt@kernel.org>,
        Matthias Brugger <matthias.bgg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:55042 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751401AbdAYJNv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 04:13:51 -0500
In-Reply-To: <1485332455-34743-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the binding was defined, I was not aware that mt2701 was an earlier
version of the SoC. For sake of consistency, the ethernet driver should
use mt2701 inside the compat string as this is the earliest SoC with the
ethernet core.

The ethernet driver is currently of no real use until we finish and
upstream the DSA driver. There are no users of this binding yet. It should
be safe to fix this now before it is too late and we need to provide
backward compatibility for the mt7623-eth compat string.

Reported-by: Sean Wang <sean.wang@mediatek.com>
Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 25ae0c5..9e75768 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2515,7 +2515,7 @@ static int mtk_remove(struct platform_device *pdev)
 }
 
 const struct of_device_id of_mtk_match[] = {
-	{ .compatible = "mediatek,mt7623-eth" },
+	{ .compatible = "mediatek,mt2701-eth" },
 	{},
 };
 MODULE_DEVICE_TABLE(of, of_mtk_match);
-- 
1.7.10.4
