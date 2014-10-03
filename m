From: Tom Herbert <therbert@google.com>
Subject: [PATCH iproute2 3/5] ip tunnel: Kernel uapi definitions for fou and gue
Date: Fri,  3 Oct 2014 08:55:16 -0700
Message-ID: <1412351718-22921-4-git-send-email-therbert@google.com>
References: <1412351718-22921-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:43520 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753782AbaJCPz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:55:56 -0400
Received: by mail-pd0-f173.google.com with SMTP id g10so2726488pdj.32
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:55:55 -0700 (PDT)
In-Reply-To: <1412351718-22921-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds definitions from kernel include/uapi/linux/if_tunnel.h
for FOU and GUE.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/if_tunnel.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 3e425f9..8b04f32 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -53,10 +53,23 @@ enum {
 	IFLA_IPTUN_6RD_RELAY_PREFIX,
 	IFLA_IPTUN_6RD_PREFIXLEN,
 	IFLA_IPTUN_6RD_RELAY_PREFIXLEN,
+	IFLA_IPTUN_ENCAP_TYPE,
+	IFLA_IPTUN_ENCAP_FLAGS,
+	IFLA_IPTUN_ENCAP_SPORT,
+	IFLA_IPTUN_ENCAP_DPORT,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
 
+enum tunnel_encap_types {
+	TUNNEL_ENCAP_NONE,
+	TUNNEL_ENCAP_FOU,
+	TUNNEL_ENCAP_GUE,
+};
+
+#define TUNNEL_ENCAP_FLAG_CSUM		(1<<0)
+#define TUNNEL_ENCAP_FLAG_CSUM6		(1<<1)
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
@@ -94,6 +107,10 @@ enum {
 	IFLA_GRE_ENCAP_LIMIT,
 	IFLA_GRE_FLOWINFO,
 	IFLA_GRE_FLAGS,
+	IFLA_GRE_ENCAP_TYPE,
+	IFLA_GRE_ENCAP_FLAGS,
+	IFLA_GRE_ENCAP_SPORT,
+	IFLA_GRE_ENCAP_DPORT,
 	__IFLA_GRE_MAX,
 };
 
-- 
2.1.0.rc2.206.gedb03e5
