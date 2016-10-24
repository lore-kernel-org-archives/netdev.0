From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: bgmac: fix spelling mistake: "connecton" -> "connection"
Date: Mon, 24 Oct 2016 23:46:18 +0100
Message-ID: <20161024224618.10383-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jon Mason <jon.mason@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59631 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755768AbcJXWqX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 18:46:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in dev_err message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 856379c..31ca204 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -1449,7 +1449,7 @@ static int bgmac_phy_connect(struct bgmac *bgmac)
 	phy_dev = phy_connect(bgmac->net_dev, bus_id, &bgmac_adjust_link,
 			      PHY_INTERFACE_MODE_MII);
 	if (IS_ERR(phy_dev)) {
-		dev_err(bgmac->dev, "PHY connecton failed\n");
+		dev_err(bgmac->dev, "PHY connection failed\n");
 		return PTR_ERR(phy_dev);
 	}
 
-- 
2.9.3
