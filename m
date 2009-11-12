From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] [PATCH] qeth: remaining EDDP cleanup
Date: Thu, 12 Nov 2009 11:11:42 +0100
Message-ID: <20091112101300.864578000@de.ibm.com>
References: <20091112101140.882313000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:60259 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbZKLKM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 05:12:56 -0500
Content-Disposition: inline; filename=607-qeth-eddp-cleanup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

EDDP code has been removed from qeth in 2009. This patch removes two
useless remaining EDDP-references.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h |    2 --
 1 file changed, 2 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_core.h
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_core.h
+++ git_net-next/drivers/s390/net/qeth_core.h
@@ -122,7 +122,6 @@ struct qeth_perf_stats {
 	__u64 outbound_do_qdio_start_time;
 	unsigned int outbound_do_qdio_cnt;
 	unsigned int outbound_do_qdio_time;
-	/* eddp data */
 	unsigned int large_send_bytes;
 	unsigned int large_send_cnt;
 	unsigned int sg_skbs_sent;
@@ -777,7 +776,6 @@ static inline void qeth_put_buffer_pool_
 	list_add_tail(&entry->list, &card->qdio.in_buf_pool.entry_list);
 }
 
-struct qeth_eddp_context;
 extern struct ccwgroup_driver qeth_l2_ccwgroup_driver;
 extern struct ccwgroup_driver qeth_l3_ccwgroup_driver;
 const char *qeth_get_cardname_short(struct qeth_card *);

