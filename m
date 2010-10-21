From: kaber@trash.net
Subject: [PATCH 38/72] netfilter: fix kconfig unmet dependency warning
Date: Thu, 21 Oct 2010 17:19:25 +0200
Message-ID: <1287674399-31455-39-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix netfilter kconfig unmet dependencies warning & spell out
"compatible" while there.

warning: (IP_NF_TARGET_TTL && NET && INET && NETFILTER && IP_NF_IPTABLES && NETFILTER_ADVANCED || IP6_NF_TARGET_HL && NET && INET && IPV6 && NETFILTER && IP6_NF_IPTABLES && NETFILTER_ADVANCED) selects NETFILTER_XT_TARGET_HL which has unmet direct dependencies ((IP_NF_MANGLE || IP6_NF_MANGLE) && NETFILTER_ADVANCED)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/Kconfig |    4 ++--
 net/ipv6/netfilter/Kconfig |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1833bdb..8e33506 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -324,10 +324,10 @@ config IP_NF_TARGET_ECN
 
 config IP_NF_TARGET_TTL
 	tristate '"TTL" target support'
-	depends on NETFILTER_ADVANCED
+	depends on NETFILTER_ADVANCED && IP_NF_MANGLE
 	select NETFILTER_XT_TARGET_HL
 	---help---
-	This is a backwards-compat option for the user's convenience
+	This is a backwards-compatible option for the user's convenience
 	(e.g. when running oldconfig). It selects
 	CONFIG_NETFILTER_XT_TARGET_HL.
 
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 29d643b..44d2eea 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -132,10 +132,10 @@ config IP6_NF_MATCH_RT
 # The targets
 config IP6_NF_TARGET_HL
 	tristate '"HL" hoplimit target support'
-	depends on NETFILTER_ADVANCED
+	depends on NETFILTER_ADVANCED && IP6_NF_MANGLE
 	select NETFILTER_XT_TARGET_HL
 	---help---
-	This is a backwards-compat option for the user's convenience
+	This is a backwards-compatible option for the user's convenience
 	(e.g. when running oldconfig). It selects
 	CONFIG_NETFILTER_XT_TARGET_HL.
 
-- 
1.7.1

