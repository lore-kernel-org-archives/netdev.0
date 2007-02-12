From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 3/3] tcp: remove experimental variants from default list
Date: Mon, 12 Feb 2007 08:03:20 -0800
Message-ID: <20070212160336.681729431@linux-foundation.org>
References: <20070212160317.545906075@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59955 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964851AbXBLQEl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 11:04:41 -0500
Content-Disposition: inline; filename=no-vegas-default.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TCP Vegas implementation is buggy, and BIC is too agressive
so they should not be in the default list. Westwood is okay, but
not well tested.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/Kconfig |   10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

--- tcp.orig/net/ipv4/Kconfig	2007-02-12 07:58:28.000000000 -0800
+++ tcp/net/ipv4/Kconfig	2007-02-12 08:00:22.000000000 -0800
@@ -581,21 +581,12 @@
 	  Select the TCP congestion control that will be used by default
 	  for all connections.
 
-	config DEFAULT_BIC
-		bool "Bic" if TCP_CONG_BIC=y
-
 	config DEFAULT_CUBIC
 		bool "Cubic" if TCP_CONG_CUBIC=y
 
 	config DEFAULT_HTCP
 		bool "Htcp" if TCP_CONG_HTCP=y
 
-	config DEFAULT_VEGAS
-		bool "Vegas" if TCP_CONG_VEGAS=y
-
-	config DEFAULT_WESTWOOD
-		bool "Westwood" if TCP_CONG_WESTWOOD=y
-
 	config DEFAULT_RENO
 		bool "Reno"
 
@@ -603,6 +594,7 @@
 
 endif
 
+# This sets the default value for those who do not choose advanced menu
 config TCP_CONG_CUBIC
 	tristate
 	depends on !TCP_CONG_ADVANCED

--

