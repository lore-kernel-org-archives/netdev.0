From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 05/10] tc: gred: Fix whitespace issues in code
Date: Mon, 18 May 2015 11:35:09 -0400
Message-ID: <1431963314-56420-6-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-5.mit.edu ([18.7.68.34]:46437 "EHLO
	dmz-mailsec-scanner-5.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932247AbbERPfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:39 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index 5e0dfcf..a3dc722 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -143,8 +143,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 				fprintf(stderr, "Illegal \"setup\"\n");
 				return -1;
 			}
-		return init_gred(qu,argc-1, argv+1,n);
-
+			return init_gred(qu, argc-1, argv+1, n);
 		} else if (strcmp(*argv, "min") == 0) {
 			NEXT_ARG();
 			if (get_size(&opt.qth_min, *argv)) {
@@ -172,7 +171,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 			ok++;
 		} else if (strcmp(*argv, "burst") == 0) {
 			NEXT_ARG();
-                        if (get_unsigned(&burst, *argv, 0)) {
+			if (get_unsigned(&burst, *argv, 0)) {
 				fprintf(stderr, "Illegal \"burst\"\n");
 				return -1;
 			}
-- 
1.7.1
