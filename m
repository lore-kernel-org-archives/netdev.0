From: baker.kernel@gmail.com
Subject: [PATCH v2 net-next] net: remove outdated comment for ipv4 and ipv6 protocol handler
Date: Tue, 26 Nov 2013 09:29:15 +0800
Message-ID: <1385429355-21442-1-git-send-email-baker.kernel@gmail.com>
References: <1385365686-17804-1-git-send-email-baker.kernel@gmail.com>
Cc: netdev@vger.kernel.org, Baker Zhang <Baker.kernel@gmail.com>
To: sergei.shtylyov@cogentembedded.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:64478 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab3KZB3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Nov 2013 20:29:48 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so6700814pdj.31
        for <netdev@vger.kernel.org>; Mon, 25 Nov 2013 17:29:48 -0800 (PST)
In-Reply-To: <1385365686-17804-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baker Zhang <Baker.kernel@gmail.com>

since f9242b6b28d61295f2bf7e8adfb1060b382e5381
inet: Sanitize inet{,6} protocol demux.

there are not pretended hash tables for ipv4 or
ipv6 protocol handler.

Signed-off-by: Baker Zhang <Baker.kernel@gmail.com>
---
V1:
inet_add_protocol/inet_del_protocol and inet6_del_protocol
are very simple in current version.

so I remove the outdated comment instead of fixing them,
just like inet6_add_protocol.

V2:
Add summary line in parens.
URL:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=f9242b6b28d61295f2bf7e8adfb1060b382e5381

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
