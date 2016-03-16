From: Luca Lemmo <luca@linux.com>
Subject: [PATCH 3/3] tc: q_{codel,fq_codel}: add missing space in help text
Date: Wed, 16 Mar 2016 17:56:14 +0100
Message-ID: <1458147374-8899-3-git-send-email-luca@linux.com>
References: <1458147374-8899-1-git-send-email-luca@linux.com>
Cc: netdev@vger.kernel.org, Luca Lemmo <luca@linux.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56054 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932079AbcCPQ5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 12:57:42 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 489C620A29
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 12:57:41 -0400 (EDT)
In-Reply-To: <1458147374-8899-1-git-send-email-luca@linux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Luca Lemmo <luca@linux.com>
---
 tc/q_codel.c    | 2 +-
 tc/q_fq_codel.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tc/q_codel.c b/tc/q_codel.c
index c24246c..cff609e 100644
--- a/tc/q_codel.c
+++ b/tc/q_codel.c
@@ -53,7 +53,7 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... codel [ limit PACKETS ] [ target TIME]\n");
+	fprintf(stderr, "Usage: ... codel [ limit PACKETS ] [ target TIME ]\n");
 	fprintf(stderr, "                 [ interval TIME ] [ ecn | noecn ]\n");
 	fprintf(stderr, "                 [ ce_threshold TIME ]\n");
 }
diff --git a/tc/q_fq_codel.c b/tc/q_fq_codel.c
index 4f747eb..0392c64 100644
--- a/tc/q_fq_codel.c
+++ b/tc/q_fq_codel.c
@@ -51,7 +51,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... fq_codel [ limit PACKETS ] [ flows NUMBER ]\n");
-	fprintf(stderr, "                    [ target TIME] [ interval TIME ]\n");
+	fprintf(stderr, "                    [ target TIME ] [ interval TIME ]\n");
 	fprintf(stderr, "                    [ quantum BYTES ] [ [no]ecn ]\n");
 	fprintf(stderr, "                    [ ce_threshold TIME ]\n");
 }
-- 
2.7.3
