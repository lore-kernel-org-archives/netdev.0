From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/8] cxgb4: Add info print to display number of MSI-X vectors allocated
Date: Wed, 21 Oct 2015 14:39:53 +0530
Message-ID: <1445418597-771-5-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:30446 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754114AbbJUJKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:04 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c29227e..a40dab7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4485,6 +4485,10 @@ static int enable_msix(struct adapter *adap)
 	}
 	for (i = 0; i < allocated; ++i)
 		adap->msix_info[i].vec = entries[i].vector;
+	dev_info(adap->pdev_dev, "%d MSI-X vectors allocated, "
+		 "nic %d iscsi %d rdma cpl %d rdma ciq %d\n",
+		 allocated, s->max_ethqsets, s->ofldqsets, s->rdmaqs,
+		 s->rdmaciqs);
 
 	kfree(entries);
 	return 0;
-- 
2.3.4
