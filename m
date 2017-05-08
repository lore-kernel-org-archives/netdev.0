From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/4] stmmac: pci: set default number of rx and tx queues
Date: Mon,  8 May 2017 17:14:19 +0300
Message-ID: <20170508141422.39612-2-andriy.shevchenko@linux.intel.com>
References: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Joao Pinto <Joao.Pinto@synopsys.com>,
        Jan Kiszka <jan.kiszka@siemens.com>,
        netdev <netdev@vger.kernel.org>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:45977 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755108AbdEHOPg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 10:15:36 -0400
In-Reply-To: <20170508141422.39612-1-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 26d6851fd24e

	("net: stmmac: set default number of rx and tx queues in stmmac_pci")

missed Intel Quark configuration. Append it here.

Fixes: 26d6851fd24e ("net: stmmac: set default number of rx and tx queues in stmmac_pci")
Cc: Joao Pinto <Joao.Pinto@synopsys.com>
Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 39be96779145..ae3e836f9bb6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -145,6 +145,10 @@ static int quark_default_data(struct plat_stmmacenet_data *plat,
 	/* Set the maxmtu to a default of JUMBO_LEN */
 	plat->maxmtu = JUMBO_LEN;
 
+	/* Set default number of RX and TX queues to use */
+	plat->tx_queues_to_use = 1;
+	plat->rx_queues_to_use = 1;
+
 	return 0;
 }
 
-- 
2.11.0
