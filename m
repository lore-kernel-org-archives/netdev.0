From: Jose Abreu <Jose.Abreu@synopsys.com>
Subject: [PATCH net] net: stmmac: dwc-qos-eth: Fix typo in DT bindings parsing
Date: Thu, 26 Oct 2017 09:51:33 +0100
Message-ID: <20c97192a6c490fbcba8fa331dd979699700a118.1509007831.git.joabreu@synopsys.com>
Cc: Jose Abreu <Jose.Abreu@synopsys.com>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        "David S. Miller" <davem@davemloft.net>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to DT bindings documentation we are expecting a
property called "snps,read-requests" but we are parsing
instead a property called "read,read-requests".

This is clearly a typo. Fix it.

Signed-off-by: Jose Abreu <joabreu@synopsys.com>
Cc: Joao Pinto <jpinto@synopsys.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre Torgue <alexandre.torgue@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
index 5efef80..3256e5c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
@@ -74,7 +74,7 @@ static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
 		plat_dat->axi->axi_wr_osr_lmt--;
 	}
 
-	if (of_property_read_u32(np, "read,read-requests",
+	if (of_property_read_u32(np, "snps,read-requests",
 				 &plat_dat->axi->axi_rd_osr_lmt)) {
 		/**
 		 * Since the register has a reset value of 1, if property
-- 
1.9.1
