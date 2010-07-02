From: kaber@trash.net
Subject: [PATCH 4/9] netfilter: fix simple typo in KConfig for netfiltert xt_TEE
Date: Fri,  2 Jul 2010 11:52:17 +0200
Message-ID: <1278064342-19059-5-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46390 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421Ab0GBJwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 05:52:25 -0400
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

Destination was spelled wrong in KConfig.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 413ed24..21be535 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -515,7 +515,7 @@ config NETFILTER_XT_TARGET_RATEEST
 	  To compile it as a module, choose M here.  If unsure, say N.
 
 config NETFILTER_XT_TARGET_TEE
-	tristate '"TEE" - packet cloning to alternate destiantion'
+	tristate '"TEE" - packet cloning to alternate destination'
 	depends on NETFILTER_ADVANCED
 	depends on (IPV6 || IPV6=n)
 	depends on !NF_CONNTRACK || NF_CONNTRACK
-- 
1.7.0.4

