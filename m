From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] net-caif: drop redundant Kconfig entries
Date: Fri, 21 May 2010 16:45:20 -0400
Message-ID: <1274474720-9865-1-git-send-email-vapier@gentoo.org>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:59790 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168Ab0EUUlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 May 2010 16:41:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is already a submenu entry that is always displayed, so there is
no need to also show a dedicated CAIF comment.

Drop dead commented code while we're here, and change the submenu text
to better match the style everyone else is using.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 net/caif/Kconfig |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/caif/Kconfig b/net/caif/Kconfig
index cd1daf6..ed65178 100644
--- a/net/caif/Kconfig
+++ b/net/caif/Kconfig
@@ -2,10 +2,8 @@
 # CAIF net configurations
 #
 
-#menu "CAIF Support"
-comment "CAIF Support"
 menuconfig CAIF
-	tristate "Enable CAIF support"
+	tristate "CAIF support"
 	select CRC_CCITT
 	default n
 	---help---
@@ -45,4 +43,3 @@ config CAIF_NETDEV
 	If unsure say Y.
 
 endif
-#endmenu
-- 
1.7.1

