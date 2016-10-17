From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [PATCH 2/2] dwc_eth_qos: enable flow control by default
Date: Mon, 17 Oct 2016 08:26:01 +0200
Message-ID: <1476685561-15625-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, Niklas Cassel <niklass@axis.com>
To: <larper@axis.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bastet.se.axis.com ([195.60.68.11]:42599 "EHLO
        bastet.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756950AbcJQG0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 02:26:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>

Allow autoneg to enable flow control by default.
The behavior when autoneg is off has not changed.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
Signed-off-by: Lars Persson <larper@axis.com>
---
 drivers/net/ethernet/synopsys/dwc_eth_qos.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/synopsys/dwc_eth_qos.c b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
index 93a3a919f723..8e39295427c0 100644
--- a/drivers/net/ethernet/synopsys/dwc_eth_qos.c
+++ b/drivers/net/ethernet/synopsys/dwc_eth_qos.c
@@ -992,6 +992,7 @@ static int dwceqos_mii_probe(struct net_device *ndev)
 	lp->speed   = 0;
 	lp->duplex  = DUPLEX_UNKNOWN;
 	lp->phy_dev = phydev;
+	lp->flowcontrol.autoneg = AUTONEG_ENABLE;
 
 	if (netif_msg_probe(lp)) {
 		netdev_dbg(lp->ndev, "phy_addr 0x%x, phy_id 0x%08x\n",
-- 
2.1.4
