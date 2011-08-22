From: Li Yu <raise.sail@gmail.com>
Subject: [net-next PATCH] tcp: remove useless assignment statement in tcp_keepalive_timer
Date: Mon, 22 Aug 2011 18:03:09 +0800
Message-ID: <4E52295D.8040901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:38789 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab1HVKDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 06:03:23 -0400
Received: by pzk37 with SMTP id 37so8412522pzk.1
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 03:03:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove useless assignment statement, it may be trash after refactoring?

Signed-off-by: Li Yu <raise.sail@gmail.com>
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index ecd44b0..321ff2f 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -552,8 +552,6 @@ static void tcp_keepalive_timer (unsigned long data)
 	if (!sock_flag(sk, SOCK_KEEPOPEN) || sk->sk_state == TCP_CLOSE)
 		goto out;
 
-	elapsed = keepalive_time_when(tp);
-
 	/* It is alive without keepalive 8) */
 	if (tp->packets_out || tcp_send_head(sk))
 		goto resched;

