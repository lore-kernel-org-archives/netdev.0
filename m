From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netdev: bfin_mac: drop experimental markings on RMII support
Date: Mon, 15 Feb 2010 19:32:50 -0500
Message-ID: <1266280370-18670-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46193 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932299Ab0BPAcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2010 19:32:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code has been around for a long time now and is known to work on a
bunch of different parts/boards.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 746cd3a..03fec5e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -868,8 +868,8 @@ config BFIN_RX_DESC_NUM
 	  Set the number of buffer packets used in driver.
 
 config BFIN_MAC_RMII
-	bool "RMII PHY Interface (EXPERIMENTAL)"
-	depends on BFIN_MAC && EXPERIMENTAL
+	bool "RMII PHY Interface"
+	depends on BFIN_MAC
 	default y if BFIN527_EZKIT
 	default n if BFIN537_STAMP
 	help
-- 
1.7.0

