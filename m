From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 3/4] stmmac: pci: RX queue routing configuration
Date: Mon,  8 May 2017 17:14:21 +0300
Message-ID: <20170508141422.39612-4-andriy.shevchenko@linux.intel.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Jan Kiszka <jan.kiszka@siemens.com>,
        netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43748 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754632AbdEHOO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 10:14:56 -0400
In-Reply-To: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit abe80fdc6ee6

    ("net: stmmac: RX queue routing configuration")

missed Intel Quark configuration. Append it here.

Fixes: abe80fdc6ee6 ("net: stmmac: RX queue routing configuration")
Cc: Joao Pinto <Joao.Pinto@synopsys.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index c015a715a8ac..2456e0a945ef 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -153,6 +153,9 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	plat->tx_queues_cfg[0].use_prio = false;
 	plat->rx_queues_cfg[0].use_prio = false;
 
+	/* Disable RX queues routing by default */
+	plat->rx_queues_cfg[0].pkt_route = 0x0;
+
 	return 0;
 }
 
-- 
2.11.0
