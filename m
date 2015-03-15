From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip link: Do not show help if 'dev he' was specified
Date: Sun, 15 Mar 2015 10:01:55 +0200
Message-ID: <1426406515-16171-1-git-send-email-vadim4j@gmail.com>
Cc: leonhard@pre.is, Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:34495 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297AbbCOINl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 04:13:41 -0400
Received: by lagg8 with SMTP id g8so17937125lag.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 01:13:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Date: Sun, 15 Mar 2015 09:11:41 +0200
Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
Reported-by: Leonhard Preis <leonhard@pre.is>
---
 ip/ipaddress.c | 3 +--
 ip/iplink.c    | 6 ++----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 99a6ab5..4879826 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1380,8 +1380,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
-			}
-			if (matches(*argv, "help") == 0)
+			} else if (matches(*argv, "help") == 0)
 				usage();
 			if (filter_dev)
 				duparg2("dev", *argv);
diff --git a/ip/iplink.c b/ip/iplink.c
index 5893ee4..664774f 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -601,8 +601,7 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
-			}
-			if (matches(*argv, "help") == 0)
+			} else if (matches(*argv, "help") == 0)
 				usage();
 			if (*dev)
 				duparg2("dev", *argv);
@@ -1088,8 +1087,7 @@ static int do_set(int argc, char **argv)
 		} else {
 			if (strcmp(*argv, "dev") == 0) {
 				NEXT_ARG();
-			}
-			if (matches(*argv, "help") == 0)
+			} else if (matches(*argv, "help") == 0)
 				usage();
 			if (dev)
 				duparg2("dev", *argv);
-- 
2.3.1
