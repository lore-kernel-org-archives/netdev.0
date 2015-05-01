From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ip link: Add group in usage() for 'ip link delete'
Date: Fri,  1 May 2015 22:26:52 +0300
Message-ID: <1430508412-15651-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:35570 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbbEAT1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 15:27:18 -0400
Received: by lbbuc2 with SMTP id uc2so70394642lbb.2
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 12:27:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Show deleting by group in 'ip link help' output:

...
ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]
...

Also show separately DEVICE option in { } list.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/iplink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index e6f30e9..023f53b 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -53,9 +53,9 @@ void iplink_usage(void)
 		fprintf(stderr, "                   [ numtxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   [ numrxqueues QUEUE_COUNT ]\n");
 		fprintf(stderr, "                   type TYPE [ ARGS ]\n");
-		fprintf(stderr, "       ip link delete DEV type TYPE [ ARGS ]\n");
+		fprintf(stderr, "       ip link delete { DEVICE | dev DEVICE | group DEVGROUP } type TYPE [ ARGS ]\n");
 		fprintf(stderr, "\n");
-		fprintf(stderr, "       ip link set { dev DEVICE | group DEVGROUP } [ { up | down } ]\n");
+		fprintf(stderr, "       ip link set { DEVICE | dev DEVICE | group DEVGROUP } [ { up | down } ]\n");
 	} else
 		fprintf(stderr, "Usage: ip link set DEVICE [ { up | down } ]\n");
 
-- 
2.3.1
