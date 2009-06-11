From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netdev: dm9000: require compat net dev ops
Date: Thu, 11 Jun 2009 19:02:30 -0400
Message-ID: <1244761350-2823-1-git-send-email-vapier@gentoo.org>
Cc: vapier.adi@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:32947 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761735AbZFKXCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 19:02:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dm9000 driver hasn't been upgraded yet, so select the compat net dev
ops option for now.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 682186b..bee902e 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -932,6 +932,7 @@ config DM9000
 	depends on ARM || BLACKFIN || MIPS
 	select CRC32
 	select MII
+	select COMPAT_NET_DEV_OPS
 	---help---
 	  Support for DM9000 chipset.
 
-- 
1.6.3.1

