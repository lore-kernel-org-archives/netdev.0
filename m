From: <richard.alpe@ericsson.com>
Subject: [PATCH iproute2] tipc: fix bearer get/set help synopsis
Date: Fri, 7 Aug 2015 09:55:09 +0200
Message-ID: <1438934109-30885-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:43535 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbbHGIKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 04:10:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

One option is required for bearer set and bearer get.
---
 tipc/bearer.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tipc/bearer.c b/tipc/bearer.c
index 33295f9..30b54d9 100644
--- a/tipc/bearer.c
+++ b/tipc/bearer.c
@@ -412,7 +412,7 @@ static int cmd_bearer_disable(struct nlmsghdr *nlh, const struct cmd *cmd,
 
 static void cmd_bearer_set_help(struct cmdl *cmdl)
 {
-	fprintf(stderr, "Usage: %s bearer set [OPTIONS] media MEDIA ARGS...\n",
+	fprintf(stderr, "Usage: %s bearer set OPTION media MEDIA ARGS...\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
 	_print_bearer_media();
@@ -420,7 +420,7 @@ static void cmd_bearer_set_help(struct cmdl *cmdl)
 
 static void cmd_bearer_set_udp_help(struct cmdl *cmdl)
 {
-	fprintf(stderr, "Usage: %s bearer set [OPTIONS] media udp name NAME\n\n",
+	fprintf(stderr, "Usage: %s bearer set OPTION media udp name NAME\n\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
 }
@@ -528,7 +528,7 @@ static int cmd_bearer_set(struct nlmsghdr *nlh, const struct cmd *cmd,
 
 static void cmd_bearer_get_help(struct cmdl *cmdl)
 {
-	fprintf(stderr, "Usage: %s bearer get [OPTIONS] media MEDIA ARGS...\n",
+	fprintf(stderr, "Usage: %s bearer get OPTION media MEDIA ARGS...\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
 	_print_bearer_media();
@@ -536,7 +536,7 @@ static void cmd_bearer_get_help(struct cmdl *cmdl)
 
 static void cmd_bearer_get_udp_help(struct cmdl *cmdl)
 {
-	fprintf(stderr, "Usage: %s bearer get [OPTIONS] media udp name NAME\n\n",
+	fprintf(stderr, "Usage: %s bearer get OPTION media udp name NAME\n\n",
 		cmdl->argv[0]);
 	_print_bearer_opts();
 }
-- 
2.1.4
