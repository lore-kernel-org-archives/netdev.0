From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2 1/3] sctp: fix some comments in chunk.c and associola.c
Date: Sat, 26 Oct 2013 16:06:30 +0800
Message-ID: <1382774792-13440-2-git-send-email-wangweidong1@huawei.com>
References: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26208 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab3JZIKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 04:10:04 -0400
In-Reply-To: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix some typos

Acked-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 4 ++--
 net/sctp/chunk.c     | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

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
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index 7bd5ed4..f2044fc 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -201,7 +201,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 
 	max = asoc->frag_point;
 	/* If the the peer requested that we authenticate DATA chunks
-	 * we need to accound for bundling of the AUTH chunks along with
+	 * we need to account for bundling of the AUTH chunks along with
 	 * DATA.
 	 */
 	if (sctp_auth_send_cid(SCTP_CID_DATA, asoc)) {
-- 
1.7.12
