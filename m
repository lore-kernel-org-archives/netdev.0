From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 5/8] qed: Add missing stat for new isles
Date: Thu, 6 Apr 2017 15:58:32 +0300
Message-ID: <1491483515-13502-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53191 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757025AbdDFM7N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 08:59:13 -0400
In-Reply-To: <1491483515-13502-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware provides a statistic for the number of out-of-order isles
it used - fill it in the iscsi-related statistics.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iscsi.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
index 112b96f..38273f4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iscsi.c
@@ -864,6 +864,8 @@ static void _qed_iscsi_get_tstats(struct qed_hwfn *p_hwfn,
 	    HILO_64_REGPAIR(tstats.iscsi_rx_bytes_cnt);
 	p_stats->iscsi_rx_packet_cnt =
 	    HILO_64_REGPAIR(tstats.iscsi_rx_packet_cnt);
+	p_stats->iscsi_rx_new_ooo_isle_events_cnt =
+	    HILO_64_REGPAIR(tstats.iscsi_rx_new_ooo_isle_events_cnt);
 	p_stats->iscsi_cmdq_threshold_cnt =
 	    le32_to_cpu(tstats.iscsi_cmdq_threshold_cnt);
 	p_stats->iscsi_rq_threshold_cnt =
-- 
1.9.3
