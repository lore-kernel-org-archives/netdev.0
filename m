From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 03/13] ip_tunnels: use offsetofend
Date: Tue, 18 Aug 2015 22:33:12 +0200
Message-ID: <49160b9c44665dfac088d4d9466755a442ca7fae.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbbHRUdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:45 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ip_tunnels.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index ca173f22f07f..cc3b39e9010b 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -23,9 +23,7 @@
 #define IPTUNNEL_ERR_TIMEO	(30*HZ)
 
 /* Used to memset ip_tunnel padding. */
-#define IP_TUNNEL_KEY_SIZE					\
-	(offsetof(struct ip_tunnel_key, tp_dst) +		\
-	 FIELD_SIZEOF(struct ip_tunnel_key, tp_dst))
+#define IP_TUNNEL_KEY_SIZE	offsetofend(struct ip_tunnel_key, tp_dst)
 
 struct ip_tunnel_key {
 	__be64			tun_id;
-- 
1.8.3.1
