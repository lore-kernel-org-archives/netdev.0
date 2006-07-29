From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 3/23] [PATCH] [XFRM]: Add Kconfig to enable advanced transformation.
Date: Sat, 29 Jul 2006 18:30:01 +0900
Message-ID: <11541654012846-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:13955 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1751201AbWG2JaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:30:08 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This option is for enhanced transformation features and it will be used by
Mobile IPv6.
Based on MIPL2 kernel patch.
---
 net/xfrm/Kconfig |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 0c1c043..95f4f09 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -14,6 +14,14 @@ config XFRM_USER
 
 	  If unsure, say Y.
 
+config XFRM_ADVANCED
+	bool "Transformation advanced functions (EXPERIMENTAL)"
+	depends on XFRM && EXPERIMENTAL
+	---help---
+	  Support advanced transformation for developers.
+
+	  If unsure, say N.
+
 config NET_KEY
 	tristate "PF_KEY sockets"
 	select XFRM
-- 
1.4.1

