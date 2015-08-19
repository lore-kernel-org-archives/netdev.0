From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 03/13] ip_tunnels: use offsetofend
Date: Wed, 19 Aug 2015 12:09:53 +0200
Message-ID: <bdf6c99e219e21ab39e4155a3a8272f2c5b762b7.1439978875.git.jbenc@redhat.com>
References: <cover.1439978875.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46891 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753644AbbHSKLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:11:35 -0400
In-Reply-To: <cover.1439978875.git.jbenc@redhat.com>
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
