From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 04/10] tc: red: Mark "bandwidth" parameter as optional in usage text
Date: Mon, 18 May 2015 11:35:08 -0400
Message-ID: <1431963314-56420-5-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-4.mit.edu ([18.9.25.15]:54864 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932251AbbERPff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:35 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_red.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_red.c b/tc/q_red.c
index 1bf2bd9..abd86c7 100644
--- a/tc/q_red.c
+++ b/tc/q_red.c
@@ -29,7 +29,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... red limit BYTES [min BYTES] [max BYTES] avpkt BYTES [burst PACKETS]\n");
-	fprintf(stderr, "               [adaptive] [probability PROBABILITY] bandwidth KBPS\n");
+	fprintf(stderr, "               [adaptive] [probability PROBABILITY] [bandwidth KBPS]\n");
 	fprintf(stderr, "               [ecn] [harddrop]\n");
 }
 
-- 
1.7.1
