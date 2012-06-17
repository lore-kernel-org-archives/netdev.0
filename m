From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2: Dump additional BC_STATE during
 firmware sync timeout.
Date: Sat, 16 Jun 2012 18:45:42 -0700
Message-ID: <1339897544-20254-2-git-send-email-mchan@broadcom.com>
References: <1339897544-20254-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2599 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757204Ab2FQBfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2012 21:35:10 -0400
In-Reply-To: <1339897544-20254-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    1 +
 drivers/net/ethernet/broadcom/bnx2.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 8eaab0c..da88de7 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -2473,6 +2473,7 @@ bnx2_dump_mcp_state(struct bnx2 *bp)
 		   bnx2_shmem_rd(bp, BNX2_BC_STATE_RESET_TYPE));
 	pr_cont(" condition[%08x]\n",
 		bnx2_shmem_rd(bp, BNX2_BC_STATE_CONDITION));
+	DP_SHMEM_LINE(bp, BNX2_BC_RESET_TYPE);
 	DP_SHMEM_LINE(bp, 0x3cc);
 	DP_SHMEM_LINE(bp, 0x3dc);
 	DP_SHMEM_LINE(bp, 0x3ec);
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 2997585..f9cb639 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -7355,6 +7355,8 @@ struct bnx2_rv2p_fw_file {
 #define BNX2_BC_STATE_RESET_TYPE_VALUE(msg) (BNX2_BC_STATE_RESET_TYPE_SIG | \
 					     (msg))
 
+#define BNX2_BC_RESET_TYPE			0x000001c0
+
 #define BNX2_BC_STATE				0x000001c4
 #define BNX2_BC_STATE_ERR_MASK			 0x0000ff00
 #define BNX2_BC_STATE_SIGN			 0x42530000
-- 
1.7.1
