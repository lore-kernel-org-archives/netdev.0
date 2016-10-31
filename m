From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] net: qcom/emac: use correct value for SGMII_LN_UCDR_SO_GAIN_MODE0
Date: Mon, 31 Oct 2016 18:18:42 -0500
Message-ID: <1477955922-18276-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:47616 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946232AbcJaXSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 19:18:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The documentation says that SGMII_LN_UCDR_SO_GAIN_MODE0 should be
set to 0, not 6, on the Qualcomm Technologies QDF2432.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index 8b3e6c3..3edb5a5 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -421,7 +421,7 @@ static const struct emac_reg_write sgmii_v2_laned[] = {
 	/* CDR Settings */
 	{EMAC_SGMII_LN_UCDR_FO_GAIN_MODE0,
 		UCDR_STEP_BY_TWO_MODE0 | UCDR_xO_GAIN_MODE(10)},
-	{EMAC_SGMII_LN_UCDR_SO_GAIN_MODE0, UCDR_xO_GAIN_MODE(6)},
+	{EMAC_SGMII_LN_UCDR_SO_GAIN_MODE0, UCDR_xO_GAIN_MODE(0)},
 	{EMAC_SGMII_LN_UCDR_SO_CONFIG, UCDR_ENABLE | UCDR_SO_SATURATION(12)},
 
 	/* TX/RX Settings */
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
