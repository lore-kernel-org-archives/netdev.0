From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 06/10] qed: Correct print in iscsi error-flow
Date: Sun, 21 May 2017 12:10:57 +0300
Message-ID: <1495357860-28280-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0071.outbound.protection.outlook.com ([104.47.34.71]:54816
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752637AbdEUJLy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:11:54 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If too many CQs are requested, qed would print the available
number as if it's a resource and not a feature leading to the
wrong print.

Fixes: 08737a3fa30a ("qed: Inform qedi the number of possible CQs")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index ac3c692..38488db 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -186,7 +186,7 @@ struct qed_iscsi_conn {
 		DP_ERR(p_hwfn,
 		       "Cannot satisfy CQ amount. Queues requested %d, CQs available %d. Aborting function start\n",
 		       p_params->num_queues,
-		       p_hwfn->hw_info.resc_num[QED_ISCSI_CQ]);
+		       p_hwfn->hw_info.feat_num[QED_ISCSI_CQ]);
 		return -EINVAL;
 	}
 
-- 
1.9.3
