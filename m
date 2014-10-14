From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net 4/4] cxgb4i: Remove duplicate call to dst_neigh_lookup()
Date: Tue, 14 Oct 2014 15:13:11 -0700
Message-ID: <1413324791-12104-5-git-send-email-anish@chelsio.com>
References: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	kxie@chelsio.com, manojmalviya@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43766
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932592AbaJNWNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 18:13:49 -0400
In-Reply-To: <1413324791-12104-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
index df176f0e5e60..8c3003b6d591 100644
--- a/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
+++ b/drivers/scsi/cxgbi/cxgb4i/cxgb4i.c
@@ -1317,11 +1317,6 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_set_flag(csk, CTPF_HAS_ATID);
 	cxgbi_sock_get(csk);
 
-	n = dst_neigh_lookup(csk->dst, &csk->daddr.sin_addr.s_addr);
-	if (!n) {
-		pr_err("%s, can't get neighbour of csk->dst.\n", ndev->name);
-		goto rel_resource;
-	}
 	csk->l2t = cxgb4_l2t_get(lldi->l2t, n, ndev, 0);
 	if (!csk->l2t) {
 		pr_err("%s, cannot alloc l2t.\n", ndev->name);
-- 
2.1.2
