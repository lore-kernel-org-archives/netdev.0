From: baker.kernel@gmail.com
Subject: [PATCH net-next] net: remove outdated comment for ipv4 and ipv6 protocol handler
Date: Mon, 25 Nov 2013 15:48:06 +0800
Message-ID: <1385365686-17804-1-git-send-email-baker.kernel@gmail.com>
Cc: netdev@vger.kernel.org, Baker Zhang <Baker.kernel@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:61885 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab3KYHsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 02:48:55 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so4962999pde.35
        for <netdev@vger.kernel.org>; Sun, 24 Nov 2013 23:48:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baker Zhang <Baker.kernel@gmail.com>

since f9242b6b28d61295f2bf7e8adfb1060b382e5381,
there are not pretended hash tables for ipv4 or
ipv6 protocol handler.

Signed-off-by: Baker Zhang <Baker.kernel@gmail.com>
---
inet_add_protocol/inet_del_protocol and inet6_del_protocol
are very simple in current version.

so I remove the outdated comment instead of fixing them,
just like inet6_add_protocol.

 net/ipv4/protocol.c | 8 --------
 net/ipv6/protocol.c | 4 ----
 2 files changed, 12 deletions(-)

diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index ce84846..46d6a1c 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -31,10 +31,6 @@
 const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
 const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
 
-/*
- *	Add a protocol handler to the hash tables
- */
-
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	if (!prot->netns_ok) {
@@ -55,10 +51,6 @@ int inet_add_offload(const struct net_offload *prot, unsigned char protocol)
 }
 EXPORT_SYMBOL(inet_add_offload);
 
-/*
- *	Remove a protocol from the hash tables.
- */
-
 int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	int ret;
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index 22d1bd4..e048cf1 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -36,10 +36,6 @@ int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol
 }
 EXPORT_SYMBOL(inet6_add_protocol);
 
-/*
- *	Remove a protocol from the hash tables.
- */
-
 int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
 	int ret;
-- 
1.8.3.2
