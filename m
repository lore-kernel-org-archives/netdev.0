From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH] sh_eth: r8a779x: Enable automatically fetch receive descriptor
Date: Thu, 13 Nov 2014 15:56:59 +0900
Message-ID: <1415861819-27812-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kouei Abe <kouei.abe.cp@renesas.com>

HDMAC automatically fetches the receive descriptor and receives frames.
Continuous reception of multiple frames is possible.

Signed-off-by: Kouei Abe <kouei.abe.cp@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on net-next tree.

 drivers/net/ethernet/renesas/sh_eth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index dbe8606..badb734 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -494,6 +494,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
 	.eesr_err_check	= EESR_TWB | EESR_TABT | EESR_RABT | EESR_RFE |
 			  EESR_RDE | EESR_RFRMER | EESR_TFE | EESR_TDE |
 			  EESR_ECI,
+	.rmcr_value	= RMCR_RNC,
 
 	.apr		= 1,
 	.mpr		= 1,
-- 
1.9.1

