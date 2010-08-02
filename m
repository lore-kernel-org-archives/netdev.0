From: kaber@trash.net
Subject: [PATCH 04/28] ipvs: Kconfig cleanup
Date: Mon,  2 Aug 2010 21:57:21 +0200
Message-ID: <1280779065-9333-5-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Marek <mmarek@suse.cz>

IP_VS_PROTO_AH_ESP should be set iff either of IP_VS_PROTO_{AH,ESP} is
selected. Express this with standard kconfig syntax.

Signed-off-by: Michal Marek <mmarek@suse.cz>
Acked-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/Kconfig |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index 712ccad..d80b41a 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -87,19 +87,16 @@ config	IP_VS_PROTO_UDP
 	  protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_AH_ESP
-	bool
-	depends on UNDEFINED
+	def_bool IP_VS_PROTO_ESP || IP_VS_PROTO_AH
 
 config	IP_VS_PROTO_ESP
 	bool "ESP load balancing support"
-	select IP_VS_PROTO_AH_ESP
 	---help---
 	  This option enables support for load balancing ESP (Encapsulation
 	  Security Payload) transport protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_AH
 	bool "AH load balancing support"
-	select IP_VS_PROTO_AH_ESP
 	---help---
 	  This option enables support for load balancing AH (Authentication
 	  Header) transport protocol. Say Y if unsure.
-- 
1.7.1

