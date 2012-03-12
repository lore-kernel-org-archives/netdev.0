From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 3/8] bnx2x: set_one_mac_e1x uses raw's state as input
Date: Mon, 12 Mar 2012 14:53:09 -0400
Message-ID: <1331578394-1153-4-git-send-email-yuvalmin@broadcom.com>
References: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3986 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754694Ab2CLL72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 07:59:28 -0400
In-Reply-To: <1331578394-1153-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, we used a hard-coded value as paramater, instead of using the
input's value. This is now remedied, as in other flows.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 2b18ccd..f913cdd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -864,7 +864,7 @@ static void bnx2x_set_one_mac_e1x(struct bnx2x *bp,
 	/* Reset the ramrod data buffer */
 	memset(config, 0, sizeof(*config));
 
-	bnx2x_vlan_mac_set_rdata_e1x(bp, o, BNX2X_FILTER_MAC_PENDING,
+	bnx2x_vlan_mac_set_rdata_e1x(bp, o, raw->state,
 				     cam_offset, add,
 				     elem->cmd_data.vlan_mac.u.mac.mac, 0,
 				     ETH_VLAN_FILTER_ANY_VLAN, config);
-- 
1.7.9.rc2
