From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 2/4] bnx2x: added cpu_to_le16 when preparing ramrod's data
Date: Mon, 12 Mar 2012 17:22:05 -0400
Message-ID: <1331587327-26279-3-git-send-email-yuvalmin@broadcom.com>
References: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4394 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012Ab2CLO2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 10:28:17 -0400
In-Reply-To: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ariel Elior <ariele@broadcom.com>

Fixed endianess issue when passing arguments to FW.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index cb6339c..94110e9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -5601,7 +5601,7 @@ static inline int bnx2x_func_send_start(struct bnx2x *bp,
 
 	/* Fill the ramrod data with provided parameters */
 	rdata->function_mode = cpu_to_le16(start_params->mf_mode);
-	rdata->sd_vlan_tag   = start_params->sd_vlan_tag;
+	rdata->sd_vlan_tag   = cpu_to_le16(start_params->sd_vlan_tag);
 	rdata->path_id       = BP_PATH(bp);
 	rdata->network_cos_mode = start_params->network_cos_mode;
 
-- 
1.7.9.rc2
