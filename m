From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip: Small corrections of '-tshort' option in usage
Date: Sun, 28 Dec 2014 11:47:43 +0200
Message-ID: <1419760063-21814-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:51846 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbaL1J54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 04:57:56 -0500
Received: by mail-wg0-f42.google.com with SMTP id k14so17146849wgh.29
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 01:57:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Fixed -t[short] to -ts[hort] as '-t' is related to
-timestamp option.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ip.c b/ip/ip.c
index 61cc9c3..850a001 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -54,7 +54,7 @@ static void usage(void)
 "                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
-"                    -o[neline] | -t[imestamp] | -t[short] | -b[atch] [filename] |\n"
+"                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |\n"
 "                    -rc[vbuf] [size] | -n[etns] name }\n");
 	exit(-1);
 }
-- 
2.1.3
