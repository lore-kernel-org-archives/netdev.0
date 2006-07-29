From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 19/23] [PATCH] [XFRM] POLICY: Add Kconfig to support sub policy.
Date: Sat, 29 Jul 2006 18:30:49 +0900
Message-ID: <1154165449785-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:30339 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1161172AbWG2Jau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:50 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 50f2fb3..9d28e88 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -22,6 +22,16 @@ config XFRM_ADVANCED
 
 	  If unsure, say N.
 
+config XFRM_SUB_POLICY
+	bool "Transformation sub policy support (EXPERIMENTAL)"
+	depends on XFRM && EXPERIMENTAL
+	---help---
+	  Support sub policy for developers. By using sub policy with main
+	  one, two policies can be applied to the same packet at once. 
+	  Policy which lives shorter time in kernel should be a sub.
+
+	  If unsure, say N.
+
 config NET_KEY
 	tristate "PF_KEY sockets"
 	select XFRM
-- 
1.4.1

