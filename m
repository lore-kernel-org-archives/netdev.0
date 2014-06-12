From: Yuval Mintz <yuval.mintz@qlogic.com>
Subject: [PATCH v2 net 2/4] bnx2x: Fix 1G-baseT link
Date: Thu, 12 Jun 2014 07:55:30 +0300
Message-ID: <1402548932-30520-3-git-send-email-yuval.mintz@qlogic.com>
References: <1402548932-30520-1-git-send-email-yuval.mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariel.elior@qlogic.com>, Yaniv Rosner <yaniv.rosner@qlogic.com>,
	Yuval Mintz <yuval.mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52305 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134AbaFLEzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 00:55:46 -0400
In-Reply-To: <1402548932-30520-1-git-send-email-yuval.mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@qlogic.com>

Set the phy access mode even in case of link-flap avoidance.

Signed-off-by: Yaniv Rosner <yaniv.rosner@qlogic.com>
Signed-off-by: Yuval Mintz <yuval.mintz@qlogic.com>
Signed-off-by: Ariel Elior <ariel.elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b052f56..3141660 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -12474,6 +12474,7 @@ static int bnx2x_avoid_link_flap(struct link_params *params,
 	u32 dont_clear_stat, lfa_sts;
 	struct bnx2x *bp = params->bp;
 
+	bnx2x_set_mdio_emac_per_phy(bp, params);
 	/* Sync the link parameters */
 	bnx2x_link_status_update(params, vars);
 
-- 
1.8.1.4
