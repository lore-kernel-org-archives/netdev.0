From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] tc: minor cleanup on ingress
Date: Sat,  9 May 2015 22:59:17 +0200
Message-ID: <03841b5cf59f51cffe7cd6ccced1c8426b484ea9.1431204884.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44652 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbbEIU7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 16:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix whitespacing and remove the unnecessary condition.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/q_ingress.c | 23 +++++++++--------------
 1 file changed, 9 insertions(+), 14 deletions(-)

diff --git a/tc/q_ingress.c b/tc/q_ingress.c
index ba58e72..30b24e7 100644
--- a/tc/q_ingress.c
+++ b/tc/q_ingress.c
@@ -34,18 +34,14 @@ static void explain(void)
 
 static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
-
-	if (argc > 0) {
-		while (argc > 0) {
-
-			if (strcmp(*argv, "handle") == 0) {
-				NEXT_ARG();
-				argc--; argv++;
-			} else {
-				fprintf(stderr, "What is \"%s\"?\n", *argv);
-				explain();
-				return -1;
-			}
+	while (argc > 0) {
+		if (strcmp(*argv, "handle") == 0) {
+			NEXT_ARG();
+			argc--; argv++;
+		} else {
+			fprintf(stderr, "What is \"%s\"?\n", *argv);
+			explain();
+			return -1;
 		}
 	}
 
@@ -55,8 +51,7 @@ static int ingress_parse_opt(struct qdisc_util *qu, int argc, char **argv, struc
 
 static int ingress_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
-
-		fprintf(f, "---------------- ");
+	fprintf(f, "---------------- ");
 	return 0;
 }
 
-- 
1.9.3
