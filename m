From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 13/18] bnx2x: Display BCM8481 FW version
Date: Mon, 02 Mar 2009 20:00:15 +0200
Message-ID: <1236016815.7723.84.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4812 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756245AbZCBSBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:01:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 13/18] bnx2x: Display BCM8481 FW version

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index c72a964..3812058 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -4244,6 +4244,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
 		status = bnx2x_format_ver(spirom_ver, version, len);
 		break;
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-- 
1.5.4.3




