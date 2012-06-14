From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH 3/3] be2net: Increase statistics structure size for skyhawk.
Date: Thu, 14 Jun 2012 11:21:45 +0530
Message-ID: <57eadb3c-1687-40a3-b846-e1fcee3f5a58@exht1.ad.emulex.com>
References: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Vasundhara Volam <vasundhara.volam@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51758 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751848Ab2FNFwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 01:52:20 -0400
In-Reply-To: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Increasing the hardware statistics structure to accomodate statistics for skyhawk.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 2f6bb06..3c938f5 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1566,7 +1566,7 @@ struct be_hw_stats_v1 {
 	u32 rsvd0[BE_TXP_SW_SZ];
 	struct be_erx_stats_v1 erx;
 	struct be_pmem_stats pmem;
-	u32 rsvd1[3];
+	u32 rsvd1[18];
 };
 
 struct be_cmd_req_get_stats_v1 {
-- 
1.7.9.5
