From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH iproute2 1/2] ip: Make uniform the use of synonyms list, show and lst
Date: Mon, 16 Mar 2015 09:59:09 +0000
Message-ID: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
Cc: netdev@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35356 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbCPJ7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 05:59:25 -0400
Received: by wibdy8 with SMTP id dy8so32922076wib.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 02:59:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Where used in the ip tool, the 'show' option always has the synonyms
'list' and 'lst', except for ip-token and ip-addrlabel, which are missing
'lst'. Add this as a synonym for these commands.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 ip/ipaddrlabel.c | 1 +
 ip/iptoken.c     | 1 +
 2 files changed, 2 insertions(+)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index b34dd8b..f6a638b 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -248,6 +248,7 @@ int do_ipaddrlabel(int argc, char **argv)
 	if (argc < 1) {
 		return ipaddrlabel_list(0, NULL);
 	} else if (matches(argv[0], "list") == 0 ||
+		   matches(argv[0], "lst") == 0 ||
 		   matches(argv[0], "show") == 0) {
 		return ipaddrlabel_list(argc-1, argv+1);
 	} else if (matches(argv[0], "add") == 0) {
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 5689c2e..655f160 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -195,6 +195,7 @@ int do_iptoken(int argc, char **argv)
 	if (argc < 1) {
 		return iptoken_list(0, NULL);
 	} else if (matches(argv[0], "list") == 0 ||
+		   matches(argv[0], "lst") == 0 ||
 		   matches(argv[0], "show") == 0) {
 		return iptoken_list(argc - 1, argv + 1);
 	} else if (matches(argv[0], "set") == 0 ||
-- 
2.1.4
