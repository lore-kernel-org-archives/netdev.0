From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net v2 5/7] bnx2x: Enable changing speed when port type is
 PORT_DA
Date: Thu, 27 Oct 2011 17:13:52 +0200
Message-ID: <1319728434-25038-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1241 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186Ab1J0NOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Oct 2011 09:14:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 1a6e37c..f0ca8b2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -329,6 +329,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
 		break;
 	case PORT_FIBRE:
+	case PORT_DA:
 		if (bp->port.supported[cfg_idx] & SUPPORTED_FIBRE)
 			break; /* no port change */
 
-- 
1.7.2.2
