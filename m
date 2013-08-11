From: Benjamin Kerensa <bkerensa@ubuntu.com>
Subject: [PATCH] ping: remove excessive punctuation in flood warning
Date: Sun, 11 Aug 2013 00:05:18 -0700
Message-ID: <CAGOdq5=P_5WukzD5Z076mr-f9NKvKVrUcn2Uubc-yRX2t3k7qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43983 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab3HKHF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 03:05:59 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so2156155pdj.17
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 00:05:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping_common.c has excessive punctuation and this patches cleans that up.

Signed-off-by: Benjamin Kerensa <bkerensa@ubuntu.com>
---
 ping_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ping_common.c b/ping_common.c
index 8d6b145..28128b0 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -608,7 +608,7 @@ void setup(int icmp_sock)
 		interval = 0;

 	if (uid && interval < MINUSERINTERVAL) {
-		fprintf(stderr, "ping: cannot flood; minimal interval, allowed for
user, is %dms\n", MINUSERINTERVAL);
+		fprintf(stderr, "ping: cannot flood; minimal interval allowed for
user is %dms\n", MINUSERINTERVAL);
 		exit(2);
 	}

-- 
1.8.3.2
