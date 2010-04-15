From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/3] ipv4: ipmr: fix IP_MROUTE_MULTIPLE_TABLES Kconfig dependencies
Date: Thu, 15 Apr 2010 14:47:56 +0200
Message-ID: <1271335678-20961-2-git-send-email-kaber@trash.net>
References: <1271335678-20961-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab0DOMsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:48:01 -0400
In-Reply-To: <1271335678-20961-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IP_MROUTE_MULTIPLE_TABLES should depend on IP_MROUTE.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index be59774..8e3a1fd 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -252,7 +252,7 @@ config IP_MROUTE
 
 config IP_MROUTE_MULTIPLE_TABLES
 	bool "IP: multicast policy routing"
-	depends on IP_ADVANCED_ROUTER
+	depends on IP_MROUTE && IP_ADVANCED_ROUTER
 	select FIB_RULES
 	help
 	  Normally, a multicast router runs a userspace daemon and decides
-- 
1.7.0.4

