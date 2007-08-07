From: Alexander Graf <sohalt@gmail.com>
Subject: [PATCH] [iputils] Print packet loss with more precision
Date: Tue,  7 Aug 2007 15:49:50 +0200
Message-ID: <11864945931233-git-send-email-sohalt@gmail.com>
References: <1186494590225-git-send-email-sohalt@gmail.com>
Cc: Alexander Graf <sohalt@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.188]:26600 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761594AbXHGNt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 09:49:57 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1679257fkz
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2007 06:49:57 -0700 (PDT)
In-Reply-To: <1186494590225-git-send-email-sohalt@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Graf <sohalt@gmail.com>
---
 ping_common.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ping_common.c b/ping_common.c
index 83be553..49acab2 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -795,9 +795,9 @@ void finish(void)
 	if (nerrors)
 		printf(", +%ld errors", nerrors);
 	if (ntransmitted) {
-		printf(", %d%% packet loss",
-		       (int) ((((long long)(ntransmitted - nreceived)) * 100) /
-			      ntransmitted));
+		printf(", %f%% packet loss",
+		       (((long long)(ntransmitted - nreceived)) * 100.0) /
+			      ntransmitted);
 		printf(", time %ldms", 1000*tv.tv_sec+tv.tv_usec/1000);
 	}
 	putchar('\n');
-- 
1.5.2.4


