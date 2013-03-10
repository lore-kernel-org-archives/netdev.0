From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next] Remove unused tw_cookie_values from tcp_timewait_sock
Date: Sun, 10 Mar 2013 16:18:39 +0100
Message-ID: <1362928719-13532-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org, william.allen.simpson@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51871 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752895Ab3CJPS4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 11:18:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tw_cookie_values is never used in the TCP-stack.

It was added by 435cf559f (TCPCT part 1d: define TCP cookie option,
extend existing struct's), but already at that time it was not used at
all, nor mentioned in the commit-message.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/linux/tcp.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f28408c..515c374 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -361,10 +361,6 @@ struct tcp_timewait_sock {
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key	  *tw_md5_key;
 #endif
-	/* Few sockets in timewait have cookies; in that case, then this
-	 * object holds a reference to them (tw_cookie_values->kref).
-	 */
-	struct tcp_cookie_values  *tw_cookie_values;
 };
 
 static inline struct tcp_timewait_sock *tcp_twsk(const struct sock *sk)
-- 
1.8.1.227.g44fe835
