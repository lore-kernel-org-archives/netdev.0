From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/5] netfilter: Don't hide NETFILTER_XT_MATCH_ADDRTYPE behind NETFILTER_ADVANCED
Date: Mon,  2 Mar 2015 12:43:44 +0100
Message-ID: <1425296627-16391-3-git-send-email-pablo@netfilter.org>
References: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425296627-16391-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Blanchard <anton@samba.org>

Docker needs NETFILTER_XT_MATCH_ADDRTYPE, so move it out from behind
NETFILTER_ADVANCED and make it default to a module.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index b02660f..c68c3b4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -951,7 +951,7 @@ comment "Xtables matches"
 
 config NETFILTER_XT_MATCH_ADDRTYPE
 	tristate '"addrtype" address type match support'
-	depends on NETFILTER_ADVANCED
+	default m if NETFILTER_ADVANCED=n
 	---help---
 	  This option allows you to match what routing thinks of an address,
 	  eg. UNICAST, LOCAL, BROADCAST, ...
-- 
1.7.10.4

