From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH] net: bridge: netfilter: Fix dependency for BRIDGE_NF_EBTABLES
Date: Tue, 10 Jan 2012 23:48:25 -0200
Message-ID: <1326246505-5038-1-git-send-email-festevam@gmail.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, Fabio Estevam <festevam@gmail.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47993 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757035Ab2AKBse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 20:48:34 -0500
Received: by yenm10 with SMTP id m10so105923yen.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 17:48:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following build warning:

warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has unmet direct dependencies (NET && INET && NETFILTER)

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 net/bridge/netfilter/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/netfilter/Kconfig b/net/bridge/netfilter/Kconfig
index a9aff9c..9ca621a 100644
--- a/net/bridge/netfilter/Kconfig
+++ b/net/bridge/netfilter/Kconfig
@@ -4,7 +4,7 @@
 
 menuconfig BRIDGE_NF_EBTABLES
 	tristate "Ethernet Bridge tables (ebtables) support"
-	depends on BRIDGE && NETFILTER
+	depends on BRIDGE && NETFILTER && INET
 	select NETFILTER_XTABLES
 	help
 	  ebtables is a general, extensible frame/packet identification
-- 
1.7.1
