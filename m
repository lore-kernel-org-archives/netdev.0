From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/6] bnx2x: Change function prototype
Date: Sat, 28 Sep 2013 08:46:10 +0300
Message-ID: <1380347172-16670-5-git-send-email-yuvalmin@broadcom.com>
References: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4238 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455Ab3I1Fqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 01:46:40 -0400
In-Reply-To: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Change bnx2x_bsc_read function prototype (more of a cosmetic change).

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index d60a2ea..92112e2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3121,7 +3121,7 @@ static void bnx2x_bsc_module_sel(struct link_params *params)
 }
 
 static int bnx2x_bsc_read(struct link_params *params,
-			  struct bnx2x_phy *phy,
+			  struct bnx2x *bp,
 			  u8 sl_devid,
 			  u16 sl_addr,
 			  u8 lc_addr,
@@ -3130,7 +3130,6 @@ static int bnx2x_bsc_read(struct link_params *params,
 {
 	u32 val, i;
 	int rc = 0;
-	struct bnx2x *bp = params->bp;
 
 	if (xfer_cnt > 16) {
 		DP(NETIF_MSG_LINK, "invalid xfer_cnt %d. Max is 16 bytes\n",
@@ -7886,7 +7885,7 @@ static int bnx2x_warpcore_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 			usleep_range(1000, 2000);
 			bnx2x_warpcore_power_module(params, 1);
 		}
-		rc = bnx2x_bsc_read(params, phy, dev_addr, addr32, 0, byte_cnt,
+		rc = bnx2x_bsc_read(params, bp, dev_addr, addr32, 0, byte_cnt,
 				    data_array);
 	} while ((rc != 0) && (++cnt < I2C_WA_RETRY_CNT));
 
-- 
1.8.1.227.g44fe835
