From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 3/4] sctp: fix some comments in associola.c
Date: Fri, 25 Oct 2013 09:50:04 +0800
Message-ID: <1382665805-13952-4-git-send-email-wangweidong1@huawei.com>
References: <1382665805-13952-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <linux-sctp@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <nhorman@tuxdriver.com>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:9617 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755706Ab3JYBu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 21:50:58 -0400
In-Reply-To: <1382665805-13952-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix some spellings

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index cef5099..c9b91cb 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -602,7 +602,7 @@ void sctp_assoc_rm_peer(struct sctp_association *asoc,
 
 		/* Start a T3 timer here in case it wasn't running so
 		 * that these migrated packets have a chance to get
-		 * retrnasmitted.
+		 * retransmitted.
 		 */
 		if (!timer_pending(&active->T3_rtx_timer))
 			if (!mod_timer(&active->T3_rtx_timer,
@@ -665,7 +665,7 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 	/* Set the path max_retrans.  */
 	peer->pathmaxrxt = asoc->pathmaxrxt;
 
-	/* And the partial failure retrnas threshold */
+	/* And the partial failure retrans threshold */
 	peer->pf_retrans = asoc->pf_retrans;
 
 	/* Initialize the peer's SACK delay timeout based on the
-- 
1.7.12
