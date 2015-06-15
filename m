From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/32] netfilter: Kconfig: get rid of parens around depends on
Date: Mon, 15 Jun 2015 23:26:25 +0200
Message-ID: <1434403589-24796-29-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the reporter, they are not needed.

Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/Kconfig |    3 ++-
 net/ipv6/netfilter/Kconfig |    3 ++-
 net/netfilter/Kconfig      |   18 +++++++++---------
 3 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index fb20f36..2199a5d 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -195,7 +195,8 @@ config IP_NF_MATCH_ECN
 
 config IP_NF_MATCH_RPFILTER
 	tristate '"rpfilter" reverse path filter match support'
-	depends on NETFILTER_ADVANCED && (IP_NF_MANGLE || IP_NF_RAW)
+	depends on NETFILTER_ADVANCED
+	depends on IP_NF_MANGLE || IP_NF_RAW
 	---help---
 	  This option allows you to match packets whose replies would
 	  go out via the interface the packet came in.
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index ca69983..b552cf0 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -186,7 +186,8 @@ config IP6_NF_MATCH_MH
 
 config IP6_NF_MATCH_RPFILTER
 	tristate '"rpfilter" reverse path filter match support'
-	depends on NETFILTER_ADVANCED && (IP6_NF_MANGLE || IP6_NF_RAW)
+	depends on NETFILTER_ADVANCED
+	depends on IP6_NF_MANGLE || IP6_NF_RAW
 	---help---
 	  This option allows you to match packets whose replies would
 	  go out via the interface the packet came in.
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index fbc8d15..6eae69a 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -206,7 +206,7 @@ config NF_CONNTRACK_FTP
 
 config NF_CONNTRACK_H323
 	tristate "H.323 protocol support"
-	depends on (IPV6 || IPV6=n)
+	depends on IPV6 || IPV6=n
 	depends on NETFILTER_ADVANCED
 	help
 	  H.323 is a VoIP signalling protocol from ITU-T. As one of the most
@@ -723,7 +723,7 @@ config NETFILTER_XT_TARGET_HL
 
 config NETFILTER_XT_TARGET_HMARK
 	tristate '"HMARK" target support'
-	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
+	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
 	depends on NETFILTER_ADVANCED
 	---help---
 	This option adds the "HMARK" target.
@@ -865,7 +865,7 @@ config NETFILTER_XT_TARGET_REDIRECT
 config NETFILTER_XT_TARGET_TEE
 	tristate '"TEE" - packet cloning to alternate destination'
 	depends on NETFILTER_ADVANCED
-	depends on (IPV6 || IPV6=n)
+	depends on IPV6 || IPV6=n
 	depends on !NF_CONNTRACK || NF_CONNTRACK
 	---help---
 	This option adds a "TEE" target with which a packet can be cloned and
@@ -875,8 +875,8 @@ config NETFILTER_XT_TARGET_TPROXY
 	tristate '"TPROXY" target transparent proxying support'
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
-	depends on (IPV6 || IPV6=n)
-	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
+	depends on IPV6 || IPV6=n
+	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
 	depends on IP_NF_MANGLE
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
@@ -915,7 +915,7 @@ config NETFILTER_XT_TARGET_SECMARK
 
 config NETFILTER_XT_TARGET_TCPMSS
 	tristate '"TCPMSS" target support'
-	depends on (IPV6 || IPV6=n)
+	depends on IPV6 || IPV6=n
 	default m if NETFILTER_ADVANCED=n
 	---help---
 	  This option adds a `TCPMSS' target, which allows you to alter the
@@ -1127,7 +1127,7 @@ config NETFILTER_XT_MATCH_ESP
 
 config NETFILTER_XT_MATCH_HASHLIMIT
 	tristate '"hashlimit" match support'
-	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
+	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
 	depends on NETFILTER_ADVANCED
 	help
 	  This option adds a `hashlimit' match.
@@ -1369,8 +1369,8 @@ config NETFILTER_XT_MATCH_SOCKET
 	depends on NETFILTER_XTABLES
 	depends on NETFILTER_ADVANCED
 	depends on !NF_CONNTRACK || NF_CONNTRACK
-	depends on (IPV6 || IPV6=n)
-	depends on (IP6_NF_IPTABLES || IP6_NF_IPTABLES=n)
+	depends on IPV6 || IPV6=n
+	depends on IP6_NF_IPTABLES || IP6_NF_IPTABLES=n
 	select NF_DEFRAG_IPV4
 	select NF_DEFRAG_IPV6 if IP6_NF_IPTABLES
 	help
-- 
1.7.10.4

