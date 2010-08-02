From: kaber@trash.net
Subject: [PATCH 23/28] ipvs: remove EXPERIMENTAL tag
Date: Mon,  2 Aug 2010 21:57:40 +0200
Message-ID: <1280779065-9333-24-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

IPVS was merged into the kernel quite a long time ago and
has been seeing wide-spread production use for even longer.

It seems appropriate for it to be no longer tagged as EXPERIMENTAL

Signed-off-as: Simon Horman <horms@verge.net.au>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/Kconfig b/net/netfilter/ipvs/Kconfig
index be10f65..46a77d5 100644
--- a/net/netfilter/ipvs/Kconfig
+++ b/net/netfilter/ipvs/Kconfig
@@ -26,7 +26,7 @@ if IP_VS
 
 config	IP_VS_IPV6
 	bool "IPv6 support for IPVS"
-	depends on EXPERIMENTAL && (IPV6 = y || IP_VS = IPV6)
+	depends on IPV6 = y || IP_VS = IPV6
 	---help---
 	  Add IPv6 support to IPVS. This is incomplete and might be dangerous.
 
-- 
1.7.1

