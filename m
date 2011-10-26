From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 5/7] bnx2x: Enable changing speed when port type is
 PORT_DA
Date: Wed, 26 Oct 2011 11:40:37 +0200
Message-ID: <1319622039-10553-6-git-send-email-yanivr@broadcom.com>
References: <1319622039-10553-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2931 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754602Ab1JZHlP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Oct 2011 03:41:15 -0400
In-Reply-To: <1319622039-10553-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_ethtool.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index cf3e479..24d7ada 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -326,6 +326,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
 		break;
 	case PORT_FIBRE:
+	case PORT_DA:
 		if (bp->port.supported[cfg_idx] & SUPPORTED_FIBRE)
 			break; /* no port change */
 
-- 
1.7.7.1
