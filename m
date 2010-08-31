From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: remove non used variable
Date: Tue, 31 Aug 2010 13:57:35 +0200
Message-ID: <1283255855.2550.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63572 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab0HaL5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 07:57:43 -0400
Received: by wyb35 with SMTP id 35so7797176wyb.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 04:57:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

remove non used variable "queue" in pg_cleanup

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/pktgen.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 10a1ea7..386c228 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3907,8 +3907,6 @@ static void __exit pg_cleanup(void)
 {
 	struct pktgen_thread *t;
 	struct list_head *q, *n;
-	wait_queue_head_t queue;
-	init_waitqueue_head(&queue);
 
 	/* Stop all interfaces & threads */
 


