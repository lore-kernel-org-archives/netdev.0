From: Frans Pop <elendil@planet.nl>
Subject: [PATCH] ipv4: make default for INET_LRO consistent with help text
Date: Fri, 15 May 2009 10:28:26 +0200
Message-ID: <200905151028.28833.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml104.kpnxchange.com ([195.121.3.8]:59468 "EHLO
	CPSMTPM-EML104.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755904AbZEOI23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2009 04:28:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e81963b1 changed this config from tristate to bool.
Add default so that it is consistent with the help text.

Signed-off-by: Frans Pop <elendil@planet.nl>

diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 9d26a3d..5b919f7 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -408,7 +408,7 @@ config INET_XFRM_MODE_BEET
 
 config INET_LRO
 	bool "Large Receive Offload (ipv4/tcp)"
-
+	default y
 	---help---
 	  Support for Large Receive Offload (ipv4/tcp).
 
