From: Peter Meerwald-Stadler <pmeerw@pmeerw.net>
Subject: [PATCH 3/3] net: fec: Fix typo in error msg and comment
Date: Fri, 16 Dec 2016 14:23:36 +0100
Message-ID: <1481894616-4517-1-git-send-email-pmeerw@pmeerw.net>
Cc: Peter Meerwald-Stadler <pmeerw@pmeerw.net>,
        Fugang Duan <fugang.duan@nxp.com>, trivial@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.pmeerw.net ([84.19.176.92]:47038 "EHLO pmeerw.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755028AbcLPNXj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 08:23:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Peter Meerwald-Stadler <pmeerw@pmeerw.net>
Cc: Fugang Duan <fugang.duan@nxp.com>
Cc: trivial@kernel.org
---
 drivers/net/ethernet/freescale/fec_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 38160c2..250b790 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2001,7 +2001,7 @@ static int fec_enet_mii_init(struct platform_device *pdev)
 		mii_speed--;
 	if (mii_speed > 63) {
 		dev_err(&pdev->dev,
-			"fec clock (%lu) to fast to get right mii speed\n",
+			"fec clock (%lu) too fast to get right mii speed\n",
 			clk_get_rate(fep->clk_ipg));
 		err = -EINVAL;
 		goto err_out;
@@ -2950,7 +2950,7 @@ static void set_multicast_list(struct net_device *ndev)
 		}
 
 		/* only upper 6 bits (FEC_HASH_BITS) are used
-		 * which point to specific bit in he hash registers
+		 * which point to specific bit in the hash registers
 		 */
 		hash = (crc >> (32 - FEC_HASH_BITS)) & 0x3f;
 
-- 
1.7.10.4
