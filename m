From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 2/2] qlcnic: Fix number of arguments in destroy tx context command
Date: Tue, 14 Oct 2014 07:41:46 -0400
Message-ID: <1413286906-14220-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:24003 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932119AbaJNMQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 08:16:28 -0400
In-Reply-To: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Number of arguments taken by destroy tx command is three
  instead of two.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 243752f..6e6f18f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -11,7 +11,7 @@ static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
 	{QLCNIC_CMD_CREATE_RX_CTX, 4, 1},
 	{QLCNIC_CMD_DESTROY_RX_CTX, 2, 1},
 	{QLCNIC_CMD_CREATE_TX_CTX, 4, 1},
-	{QLCNIC_CMD_DESTROY_TX_CTX, 2, 1},
+	{QLCNIC_CMD_DESTROY_TX_CTX, 3, 1},
 	{QLCNIC_CMD_INTRPT_TEST, 4, 1},
 	{QLCNIC_CMD_SET_MTU, 4, 1},
 	{QLCNIC_CMD_READ_PHY, 4, 2},
-- 
1.6.3.3
