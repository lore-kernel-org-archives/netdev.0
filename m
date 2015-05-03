From: =?UTF-8?q?J=CE=B5an=20Sacren?= <sakiwit@gmail.com>
Subject: [PATCH net-next] sock: fix comment location
Date: Sun,  3 May 2015 14:55:19 -0600
Message-ID: <1430686519-20548-1-git-send-email-sakiwit@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:35012 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbbECU7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 May 2015 16:59:12 -0400
Received: by obcux3 with SMTP id ux3so94727383obc.2
        for <netdev@vger.kernel.org>; Sun, 03 May 2015 13:59:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

The block of comment is for 'sk_incoming_cpu' rather than 'sk_txhash'.
Therefore, move it above "u16 sk_incoming_cpu;" where it belongs.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 3a4898ec8c67..42a8670e5baf 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -352,11 +352,11 @@ struct sock {
 #ifdef CONFIG_RPS
 	__u32			sk_rxhash;
 #endif
-	u16			sk_incoming_cpu;
 	/* 16bit hole
 	 * Warned : sk_incoming_cpu can be set from softirq,
 	 * Do not use this hole without fully understanding possible issues.
 	 */
+	u16			sk_incoming_cpu;
 
 	__u32			sk_txhash;
 #ifdef CONFIG_NET_RX_BUSY_POLL
