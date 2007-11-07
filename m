From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 01/13] SCTP : Fix bad formatted comment in outqueue.c
Date: Wed,  7 Nov 2007 12:46:19 -0500
Message-ID: <11944575912498-git-send-email-vladislav.yasevich@hp.com>
References: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:39382 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194AbXKGSEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 13:04:54 -0500
In-Reply-To: <11944575911538-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Just fix the bad format of the comment in outqueue.c.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/outqueue.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 28f4fe7..e315c6c 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -641,7 +641,8 @@ static int sctp_outq_flush_rtx(struct sctp_outq *q, struct sctp_packet *pkt,
 
 		/* If we are here due to a retransmit timeout or a fast
 		 * retransmit and if there are any chunks left in the retransmit
-		 * queue that could not fit in the PMTU sized packet, they need			 * to be marked as ineligible for a subsequent fast retransmit.
+		 * queue that could not fit in the PMTU sized packet, they need
+		 * to be marked as ineligible for a subsequent fast retransmit.
 		 */
 		if (rtx_timeout && !lchunk) {
 			list_for_each(lchunk1, lqueue) {
-- 
1.5.2.4

