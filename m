From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net-next 4/5] qlcnic: Dump mailbox command data when a command times out
Date: Thu, 15 Aug 2013 08:27:28 -0400
Message-ID: <1376569649-565-5-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:35262 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756305Ab3HONfN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 09:35:13 -0400
In-Reply-To: <1376569649-565-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 43b51a0..78ca755 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -3736,6 +3736,7 @@ static void qlcnic_83xx_mailbox_worker(struct work_struct *work)
 				__func__, cmd->cmd_op, cmd->type, ahw->pci_func,
 				ahw->op_mode);
 			clear_bit(QLC_83XX_MBX_READY, &mbx->status);
+			qlcnic_dump_mbx(adapter, cmd);
 			qlcnic_83xx_idc_request_reset(adapter,
 						      QLCNIC_FORCE_FW_DUMP_KEY);
 			cmd->rsp_opcode = QLCNIC_RCODE_TIMEOUT;
-- 
1.8.1.4
