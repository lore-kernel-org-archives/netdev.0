From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 4/5] bnx2x: Remove AutoGrEEEn for BCM84833
Date: Tue, 17 Jan 2012 14:33:28 +0200
Message-ID: <1326803609-25526-5-git-send-email-yanivr@broadcom.com>
References: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4193 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097Ab2AQKez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 05:34:55 -0500
In-Reply-To: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable the autoGrEEEn feature for BCM84833.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 1d1a809..a6c48d6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9814,12 +9814,8 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) {
 		bnx2x_84833_pair_swap_cfg(phy, params, vars);
 
-		/* AutogrEEEn */
-		if (params->feature_config_flags &
-			FEATURE_CONFIG_AUTOGREEEN_ENABLED)
-			cmd_args[0] = 0x2;
-		else
-			cmd_args[0] = 0x0;
+		/* Keep AutogrEEEn disabled. */
+		cmd_args[0] = 0x0;
 		cmd_args[1] = 0x0;
 		cmd_args[2] = PHY84833_CONSTANT_LATENCY + 1;
 		cmd_args[3] = PHY84833_CONSTANT_LATENCY;
-- 
1.7.7.1
