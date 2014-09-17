From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 net-next 1/7] net: Export inet_offloads and inet6_offloads
Date: Wed, 17 Sep 2014 12:25:55 -0700
Message-ID: <1410981961-15545-2-git-send-email-therbert@google.com>
References: <1410981961-15545-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:51384 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756657AbaIQT0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 15:26:17 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so2718314pad.34
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 12:26:16 -0700 (PDT)
In-Reply-To: <1410981961-15545-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Want to be able to use these in foo-over-udp offloads, etc.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/protocol.c | 1 +
 net/ipv6/protocol.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 46d6a1c..4b7c0ec 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -30,6 +30,7 @@
 
 const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
 const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS] __read_mostly;
+EXPORT_SYMBOL(inet_offloads);
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index e048cf1..e3770ab 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -51,6 +51,7 @@ EXPORT_SYMBOL(inet6_del_protocol);
 #endif
 
 const struct net_offload __rcu *inet6_offloads[MAX_INET_PROTOS] __read_mostly;
+EXPORT_SYMBOL(inet6_offloads);
 
 int inet6_add_offload(const struct net_offload *prot, unsigned char protocol)
 {
-- 
2.1.0.rc2.206.gedb03e5
