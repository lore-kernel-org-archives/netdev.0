From: Christian Hesse <mail@eworm.de>
Subject: [PATCH 1/1] ip-link: fix column alignment
Date: Mon,  3 Nov 2014 08:21:11 +0100
Message-ID: <1414999271-18155-1-git-send-email-mail@eworm.de>
Cc: netdev@vger.kernel.org, Christian Hesse <mail@eworm.de>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([148.251.109.235]:50102 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaKCHVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 02:21:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Width is the maximum number of characters used for the value, excluding a
field separator. So append a single whitespace.
---
 ip/ipaddress.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index efea88c..e240bb5 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -327,7 +327,7 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 	char buf[64];
 
 	if (!human_readable || count < base) {
-		fprintf(fp, "%-*"PRIu64, width, count);
+		fprintf(fp, "%-*"PRIu64" ", width, count);
 		return;
 	}
 
@@ -346,7 +346,7 @@ static void print_num(FILE *fp, unsigned width, uint64_t count)
 	snprintf(buf, sizeof(buf), "%.1f%c%s", (double) count / powi, 
 		 *prefix, use_iec ? "i" : "");
 
-	fprintf(fp, "%-*s", width, buf);
+	fprintf(fp, "%-*s ", width, buf);
 }
 
 static void print_link_stats64(FILE *fp, const struct rtnl_link_stats64 *s,
-- 
2.1.3
