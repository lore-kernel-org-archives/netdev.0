From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: [RFC][PATCH][XFRM][5/5] extension to XFRM for dynamic endpoint update (MIGRATE)
Date: Thu, 01 Feb 2007 13:10:42 +0900
Message-ID: <20070201114626.E2C5.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Francis Dupont <Francis.Dupont@point6.net>,
	Masahide Nakamura <nakam@linux-ipv6.org>,
	usagi-core@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:42354 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161182AbXBAEch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 23:32:37 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shinta Sugimoto <shinta@sfc.wide.ad.jp>

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 0faab63..fbaab2f 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -34,4 +41,14 @@ config NET_KEY
 
 	  Say Y unless you know what you are doing.
 
+config NET_KEY_MIGRATE
+	bool "PF_KEY MIGRATE (EXPERIMENTAL)"
+	depends on NET_KEY && EXPERIMENTAL
+	select XFRM_MIGRATE
+	---help---
+	  Add a PF_KEY MIGRATE message to PF_KEYv2 socket family.
+	  The PF_KEY MIGRATE message is used to dynamically update
+	  locator(s) of a given IPsec security association.  This feature
+	  is required, for instance, in a Mobile IPv6 environment where
+	  a mobile node changes its attachment point to the Internet.
 

