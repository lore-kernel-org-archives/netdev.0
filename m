From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.25][NEIGH]: Add a comment describing what a NUD stands
 for.
Date: Thu, 10 Jan 2008 18:05:25 +0300
Message-ID: <47863435.3090407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47996 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760683AbYAJPFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 10:05:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When I studied the neighbor code I puzzled over what
the NUD can mean for quite a long time.

Finally I asked Alexey and he said that this was smth
like "neighbor unreachability detection".

Does it worth adding a comment helping future developers 
understand what's going on?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 09f9fc6..bc34144 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -26,6 +26,10 @@
 #include <linux/sysctl.h>
 #include <net/rtnetlink.h>
 
+/*
+ * NUD stands for "neighbor unreachability detection"
+ */
+
 #define NUD_IN_TIMER	(NUD_INCOMPLETE|NUD_REACHABLE|NUD_DELAY|NUD_PROBE)
 #define NUD_VALID	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE|NUD_PROBE|NUD_STALE|NUD_DELAY)
 #define NUD_CONNECTED	(NUD_PERMANENT|NUD_NOARP|NUD_REACHABLE)
