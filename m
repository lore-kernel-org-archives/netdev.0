From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/core/request_sock.c: remove unused exports
Date: Sat, 17 Nov 2007 12:58:48 +0100
Message-ID: <20071117115848.GB4250@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:52297 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754280AbXKQL7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 06:59:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the following unused EXPORT_SYMBOL's:
- reqsk_queue_alloc
- __reqsk_queue_destroy
- reqsk_queue_destroy

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/core/request_sock.c |    5 -----
 1 file changed, 5 deletions(-)

3761f092ccd5d87a1517b55e2001ac9ef189b901 
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 45aed75..2d3035d 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -69,8 +69,6 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
 	return 0;
 }
 
-EXPORT_SYMBOL(reqsk_queue_alloc);
-
 void __reqsk_queue_destroy(struct request_sock_queue *queue)
 {
 	struct listen_sock *lopt;
@@ -91,8 +89,6 @@ void __reqsk_queue_destroy(struct request_sock_queue *queue)
 		kfree(lopt);
 }
 
-EXPORT_SYMBOL(__reqsk_queue_destroy);
-
 static inline struct listen_sock *reqsk_queue_yank_listen_sk(
 		struct request_sock_queue *queue)
 {
@@ -134,4 +130,3 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 		kfree(lopt);
 }
 
-EXPORT_SYMBOL(reqsk_queue_destroy);

