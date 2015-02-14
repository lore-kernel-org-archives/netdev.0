From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip xfrm: Allow to specify "all" option for monitor
Date: Sat, 14 Feb 2015 19:45:04 +0200
Message-ID: <1423935904-6395-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:55873 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbbBNR4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 12:56:12 -0500
Received: by mail-lb0-f179.google.com with SMTP id w7so20771677lbi.10
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 09:56:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Just to be aligned with the usage output.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/xfrm_monitor.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 79453e4..8aa6f49 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -374,7 +374,7 @@ int do_xfrm_monitor(int argc, char **argv)
 			groups = 0;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
-		} else {
+		} else if (strcmp(*argv, "all")) {
 			fprintf(stderr, "Argument \"%s\" is unknown, try \"ip xfrm monitor help\".\n", *argv);
 			exit(-1);
 		}
-- 
2.2.2
