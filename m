From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 5/5] qed: Enable hardware GRO feature for encapsulated packets
Date: Wed, 22 Jun 2016 04:25:26 -0400
Message-ID: <1466583926-27762-6-git-send-email-manish.chopra@qlogic.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43055 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751138AbcFVJJj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:09:39 -0400
In-Reply-To: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch actually enables the hardware to perform GRO over
encapsulated Ipv4/Ipv6 packets.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_l2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index d121a8b..e56981d 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -92,6 +92,8 @@ int qed_sp_eth_vport_start(struct qed_hwfn *p_hwfn,
 		p_ramrod->tpa_param.tpa_min_size_to_start = p_params->mtu / 2;
 		p_ramrod->tpa_param.tpa_ipv4_en_flg = 1;
 		p_ramrod->tpa_param.tpa_ipv6_en_flg = 1;
+		p_ramrod->tpa_param.tpa_ipv4_tunn_en_flg = 1;
+		p_ramrod->tpa_param.tpa_ipv6_tunn_en_flg = 1;
 		p_ramrod->tpa_param.tpa_pkt_split_flg = 1;
 		p_ramrod->tpa_param.tpa_gro_consistent_flg = 1;
 		break;
-- 
2.7.2
