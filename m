From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] net: remove stale reference to fastroute from Kconfig help text
Date: Fri, 8 May 2009 01:24:27 +0200
Message-ID: <20090507232427.GP24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:39821 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbZEGXRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 19:17:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ashish Karkare <akarkare@marvell.com>

Signed-off-by: Ashish Karkare <akarkare@marvell.com>
Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 net/Kconfig |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index ce77db4..c19f549 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -119,12 +119,6 @@ menuconfig NETFILTER
 	  <file:Documentation/Changes> under "iptables" for the location of
 	  these packages.
 
-	  Make sure to say N to "Fast switching" below if you intend to say Y
-	  here, as Fast switching currently bypasses netfilter.
-
-	  Chances are that you should say Y here if you compile a kernel which
-	  will run as a router and N for regular hosts. If unsure, say N.
-
 if NETFILTER
 
 config NETFILTER_DEBUG
-- 
1.5.6.4
