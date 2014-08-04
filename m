From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next] cxgb4i : Move stray CPL definitions to cxgb4 driver
Date: Mon,  4 Aug 2014 16:17:51 -0700
Message-ID: <1407194271-620-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hch@infradead.org, kxie@chelsio.com,
	hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:58304
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752583AbaHDXTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 19:19:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These belong to the t4 msg header, will ensure there is no accidental code
duplication in the future

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h | 2 ++
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c          | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index 0259feeab1b3..52e08103f221 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -75,6 +75,7 @@ enum {
 	CPL_RX_DATA_DDP       = 0x42,
 	CPL_PASS_ACCEPT_REQ   = 0x44,
 	CPL_TRACE_PKT_T5      = 0x48,
+	CPL_RX_ISCSI_DDP      = 0x49,
 
 	CPL_RDMA_READ_REQ     = 0x60,
 
@@ -86,6 +87,7 @@ enum {
 	CPL_SGE_EGR_UPDATE    = 0xA5,
 
 	CPL_TRACE_PKT         = 0xB0,
+	CPL_ISCSI_DATA	      = 0xB2,
 
 	CPL_FW4_MSG           = 0xC0,
 	CPL_FW4_PLD           = 0xC1,
diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index d31f9e600639..79788a12712d 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1384,8 +1384,6 @@ rel_resource:
 	return -EINVAL;
 }
 
-#define CPL_ISCSI_DATA		0xB2
-#define CPL_RX_ISCSI_DDP	0x49
 cxgb4i_cplhandler_func cxgb4i_cplhandlers[NUM_CPL_CMDS] = {
 	[CPL_ACT_ESTABLISH] = do_act_establish,
 	[CPL_ACT_OPEN_RPL] = do_act_open_rpl,
-- 
2.0.3
