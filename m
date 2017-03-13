From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] net: stmmac: set default number of rx and tx queues in stmmac_pci
Date: Mon, 13 Mar 2017 10:07:07 +0000
Message-ID: <d8f9e892defdcaf7f7e5fe795f2072b16f7e6b87.1489399548.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay2.synopsys.com ([198.182.60.111]:52394 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdCMKHM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 06:07:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch configures default number of RX and TX queues when
using the pci glue driver.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 5c9e4622..cea472a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -88,6 +88,10 @@ static void stmmac_default_data(struct plat_stmmacenet_data *plat)
 
 	/* Set the maxmtu to a default of JUMBO_LEN */
 	plat->maxmtu = JUMBO_LEN;
+
+	/* Set default number of RX and TX queues to use */
+	plat->tx_queues_to_use = 1;
+	plat->rx_queues_to_use = 1;
 }
 
 static int quark_default_data(struct plat_stmmacenet_data *plat,
-- 
2.9.3
