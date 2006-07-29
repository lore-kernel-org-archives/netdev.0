From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/20] [PATCH] [IPV6]: Add Kconfig to enable Mobile IPv6.
Date: Sat, 29 Jul 2006 18:38:12 +0900
Message-ID: <11541658921982-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:35203 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422708AbWG2JiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:14 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on MIPL2 kernel patch.
---
 net/ipv6/Kconfig |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index f8a107a..06b1c3a 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -115,3 +115,12 @@ config IPV6_TUNNEL
 
 	  If unsure, say N.
 
+config IPV6_MIP6
+	bool "IPv6: Mobility (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	select XFRM
+	select XFRM_ADVANCED
+	---help---
+	  Support for IPv6 Mobility described in RFC 3775.
+
+	  If unsure, say N.
-- 
1.4.1

