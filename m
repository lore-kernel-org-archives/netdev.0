From: Qinghuang Feng <qhfeng.kernel@gmail.com>
Subject: [PATCH] NET: fix wrong English expression in comments
Date: Mon, 12 Jan 2009 02:36:59 +0800
Message-ID: <496a3c51.09876e0a.03fe.7e80@mx.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:64321 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbZAKShH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 13:37:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Qinghuang Feng <qhfeng.kernel@gmail.com>
---
diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 4b8ece2..2540d3a 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -103,7 +103,7 @@ struct inet_bind_bucket;
 struct inet_timewait_sock {
 	/*
 	 * Now struct sock also uses sock_common, so please just
-	 * don't add nothing before this first member (__tw_common) --acme
+	 * don't add anything before this first member (__tw_common) --acme
 	 */
 	struct sock_common	__tw_common;
 #define tw_family		__tw_common.skc_family
diff --git a/include/net/sock.h b/include/net/sock.h
index 5a3a151..a587e9d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -204,7 +204,7 @@ struct sock_common {
 struct sock {
 	/*
 	 * Now struct inet_timewait_sock also uses sock_common, so please just
-	 * don't add nothing before this first member (__sk_common) --acme
+	 * don't add anything before this first member (__sk_common) --acme
 	 */
 	struct sock_common	__sk_common;
 #define sk_family		__sk_common.skc_family

