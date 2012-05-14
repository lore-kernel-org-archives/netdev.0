From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH] net/bridge/netfilter: Fix the randconfig warning
Date: Tue, 15 May 2012 01:00:17 +0530
Message-ID: <1337023817-26132-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

when ran with make randconfig got

warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has unmet direct dependencies (NET && INET && NETFILTER)

added NET && INET && NETFILTER dependency to the BRIDGE_NF_EBTABLES

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 net/bridge/netfilter/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index a9aff9c..34f6d9d 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -4,7 +4,7 @@
 
 menuconfig BRIDGE_NF_EBTABLES
 	tristate "Ethernet Bridge tables (ebtables) support"
-	depends on BRIDGE && NETFILTER
+	depends on NET && INET && BRIDGE && NETFILTER
 	select NETFILTER_XTABLES
 	help
 	  ebtables is a general, extensible frame/packet identification
-- 
1.7.9.5

