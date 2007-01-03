From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] proper prototype for x25_init_timers()
Date: Thu, 4 Jan 2007 00:09:28 +0100
Message-ID: <20070103230928.GP20714@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-x25@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:1036 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932169AbXACXJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 18:09:25 -0500
To: netdev@vger.kernel.org, eis@baty.hanse.de
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a proper prototype for x25_init_timers() in 
include/net/x25.h

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/x25.h |    1 +
 net/x25/af_x25.c  |    2 --
 2 files changed, 1 insertion(+), 2 deletions(-)

--- linux-2.6.20-rc2-mm1/include/net/x25.h.old	2007-01-03 22:57:52.000000000 +0100
+++ linux-2.6.20-rc2-mm1/include/net/x25.h	2007-01-03 22:58:17.000000000 +0100
@@ -259,6 +259,7 @@
 extern void x25_disconnect(struct sock *, int, unsigned char, unsigned char);
 
 /* x25_timer.c */
+extern void x25_init_timers(struct sock *sk);
 extern void x25_start_heartbeat(struct sock *);
 extern void x25_start_t2timer(struct sock *);
 extern void x25_start_t21timer(struct sock *);
--- linux-2.6.20-rc2-mm1/net/x25/af_x25.c.old	2007-01-03 22:58:28.000000000 +0100
+++ linux-2.6.20-rc2-mm1/net/x25/af_x25.c	2007-01-03 22:58:35.000000000 +0100
@@ -484,8 +484,6 @@
 	return sk;
 }
 
-void x25_init_timers(struct sock *sk);
-
 static int x25_create(struct socket *sock, int protocol)
 {
 	struct sock *sk;

