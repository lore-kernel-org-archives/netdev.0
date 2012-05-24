From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH IPROUTE2] tc-codel: Update usage text
Date: Thu, 24 May 2012 11:48:07 -0700
Message-ID: <1337885287-31354-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34775 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933940Ab2EXSqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 14:46:02 -0400
Received: by pbbrp8 with SMTP id rp8so630745pbb.19
        for <netdev@vger.kernel.org>; Thu, 24 May 2012 11:46:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

codel can take 'noecn' as an option. This also makes it consistent with the
manpage.

Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 tc/q_codel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_codel.c b/tc/q_codel.c
index 826285a..dc4b3f6 100644
--- a/tc/q_codel.c
+++ b/tc/q_codel.c
@@ -54,7 +54,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... codel [ limit PACKETS ] [ target TIME]\n");
-	fprintf(stderr, "                 [ interval TIME ] [ ecn ]\n");
+	fprintf(stderr, "                 [ interval TIME ] [ ecn | noecn ]\n");
 }
 
 static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,
-- 
1.7.0.4
