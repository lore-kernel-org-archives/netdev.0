From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] unix: Remove unused field from unix_sock
Date: Fri, 12 Oct 2012 18:53:10 +0400
Message-ID: <50782ED6.7090704@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38741 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759597Ab2JLOxU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 10:53:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The struct sock *other one seem to be unused. Grep and make do not object.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index b5f8988..0a996a3 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -53,7 +53,6 @@ struct unix_sock {
 	struct path		path;
 	struct mutex		readlock;
 	struct sock		*peer;
-	struct sock		*other;
 	struct list_head	link;
 	atomic_long_t		inflight;
 	spinlock_t		lock;
