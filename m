From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH 1/3] TIPC: Removing EXPERIMENTAL label
Date: Mon, 21 May 2012 01:59:12 -0400
Message-ID: <1337579954-17161-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	ying.xue@windriver.com, erik.hugne@ericsson.com,
	allan.stephens@windriver.com, maloy@donjonn.com,
	Jon Maloy <jon.maloy@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm15.access.bullet.mail.mud.yahoo.com ([66.94.237.216]:28758
	"HELO nm15.access.bullet.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751546Ab2EUGGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2012 02:06:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the latest series of patches from Paul Gortmaker and Allan
Stephens TIPC is now functionally mature and stable enough to
justify removal of the EXPERIMENTAL label.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/Kconfig b/net/tipc/Kconfig
index 2c5954b..fdc1625 100644
--- a/net/tipc/Kconfig
+++ b/net/tipc/Kconfig
@@ -3,8 +3,8 @@
 #
 
 menuconfig TIPC
-	tristate "The TIPC Protocol (EXPERIMENTAL)"
-	depends on INET && EXPERIMENTAL
+	tristate "The TIPC Protocol"
+	depends on INET
 	---help---
 	  The Transparent Inter Process Communication (TIPC) protocol is
 	  specially designed for intra cluster communication. This protocol
-- 
1.7.9.5
