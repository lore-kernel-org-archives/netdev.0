From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [RFC][PATCH][XFRM][3/5] extension to XFRM for dynamic endpoint update (MIGRATE)
Date: Thu, 01 Feb 2007 13:10:40 +0900
Message-ID: <20070201114533.E2C1.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:42355 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161181AbXBAEch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 23:32:37 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shinta Sugimoto <shinta@sfc.wide.ad.jp>

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 0faab63..fbaab2f 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -24,6 +24,13 @@ config XFRM_SUB_POLICY
 
 	  If unsure, say N.
 
+config XFRM_MIGRATE
+	bool "Transformation migrate database (EXPERIMENTAL)"
+	depends on XFRM && EXPERIMENTAL
+	---help---
+	  A feature to update locator(s) of a given IPsec security
+	  association dynamically.
+
 config NET_KEY
 	tristate "PF_KEY sockets"
 	select XFRM

