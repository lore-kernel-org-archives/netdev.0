From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/2] netdev: smsc911x: allow building on Blackfin systems
Date: Fri,  5 Jun 2009 20:37:19 -0400
Message-ID: <1244248640-22699-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:56135 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752399AbZFFAhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jun 2009 20:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smsc911x driver works fine on Blackfin systems, so add it to the arch
list in the Kconfig.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
side note ... does it even make sense to have this arch list in the first
place ?  the driver works with any platform who declares proper platform
resources ...

 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 214a92d..962b261 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1000,7 +1000,7 @@ config SMC911X
 
 config SMSC911X
 	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
-	depends on ARM || SUPERH
+	depends on ARM || SUPERH || BLACKFIN
 	select CRC32
 	select MII
 	select PHYLIB
-- 
1.6.3.1

