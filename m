From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net: ethoc: Make needlessly global struct ethtool_ops static
Date: Tue, 17 Jan 2017 15:01:08 +0100
Message-ID: <20170117140108.1544-1-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Thierry Reding <thierry.reding@gmail.com>,
        Colin Ian King <colin.king@canonical.com>,
        Philippe Reynes <tremyfr@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:60748 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750923AbdAQOBe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 09:01:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the needlessly global struct ethtool_ops ethoc_ethtool_ops static
to fix a sparse warning.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/ethoc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 63e5e14174ee..c45757af9ade 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -995,7 +995,7 @@ static int ethoc_set_ringparam(struct net_device *dev,
 	return 0;
 }
 
-const struct ethtool_ops ethoc_ethtool_ops = {
+static const struct ethtool_ops ethoc_ethtool_ops = {
 	.get_regs_len = ethoc_get_regs_len,
 	.get_regs = ethoc_get_regs,
 	.nway_reset = phy_ethtool_nway_reset,
-- 
2.11.0
