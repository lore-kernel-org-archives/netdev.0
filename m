From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/dccp/: Spelling fixes
Date: Mon, 17 Dec 2007 11:40:30 -0800
Message-ID: <1197920439-5455-24-git-send-email-joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	dccp@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:3222 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763159AbXLQTl3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 14:41:29 -0500
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918894.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/dccp/ackvec.h      |    2 +-
 net/dccp/ccids/ccid3.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 9ef0737..9671ecd 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -71,7 +71,7 @@ struct dccp_ackvec {
  * @dccpavr_ack_ackno - sequence number being acknowledged
  * @dccpavr_ack_ptr - pointer into dccpav_buf where this record starts
  * @dccpavr_ack_nonce - dccpav_ack_nonce at the time this record was sent
- * @dccpavr_sent_len - lenght of the record in dccpav_buf
+ * @dccpavr_sent_len - length of the record in dccpav_buf
  */
 struct dccp_ackvec_record {
 	struct list_head dccpavr_node;
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 19b3358..d133416 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -239,7 +239,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
 			       (unsigned)(hctx->ccid3hctx_x >> 6));
 		/* The value of R is still undefined and so we can not recompute
-		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
+		 * the timeout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 		ccid3_update_send_interval(hctx);
 		break;
-- 
1.5.3.7.949.g2221a6

