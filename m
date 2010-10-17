From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH resend] netfilter: fix kconfig unmet dependency warning
Date: Sat, 16 Oct 2010 19:11:03 -0700
Message-ID: <20101016191103.ba9b2e7e.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix netfilter kconfig unmet dependencies warning & spell out
"compatible" while there.

warning: (IP_NF_TARGET_TTL && NET && INET && NETFILTER && IP_NF_IPTABLES && NETFILTER_ADVANCED || IP6_NF_TARGET_HL && NET && INET && IPV6 && NETFILTER && IP6_NF_IPTABLES && NETFILTER_ADVANCED) selects NETFILTER_XT_TARGET_HL which has unmet direct dependencies ((IP_NF_MANGLE || IP6_NF_MANGLE) && NETFILTER_ADVANCED)

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/ipv4/netfilter/Kconfig |    4 ++--
 net/ipv6/netfilter/Kconfig |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

[orig. sent 2010-SEP-23]

--- linux-next-20100921.orig/net/ipv4/netfilter/Kconfig
+++ linux-next-20100921/net/ipv4/netfilter/Kconfig
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
 
--- linux-next-20100921.orig/net/ipv6/netfilter/Kconfig
+++ linux-next-20100921/net/ipv6/netfilter/Kconfig
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
