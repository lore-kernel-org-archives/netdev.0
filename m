From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/6] qed: configure the RoCE max message size
Date: Sun, 30 Apr 2017 11:49:05 +0300
Message-ID: <1493542150-21826-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ram.Amrani@cavium.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0077.outbound.protection.outlook.com ([104.47.34.77]:22282
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2998981AbdD3It3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 04:49:29 -0400
In-Reply-To: <1493542150-21826-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index b8c811f..5d40615 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -750,6 +750,8 @@ static struct qed_rdma_port *qed_rdma_query_port(void *rdma_cxt)
 
 	p_port->link_speed = p_hwfn->mcp_info->link_output.speed;
 
+	p_port->max_msg_size = RDMA_MAX_DATA_SIZE_IN_WQE;
+
 	return p_port;
 }
 
-- 
1.9.3
