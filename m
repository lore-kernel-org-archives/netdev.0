From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/2 v3] netdev: smsc911x: allow building on any system
Date: Tue,  9 Jun 2009 05:13:39 -0400
Message-ID: <1244538819-11305-1-git-send-email-vapier@gentoo.org>
References: <20090609.013718.135786197.davem@davemloft.net>
Cc: uclinux-dist-devel@blackfin.uclinux.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:37939 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943AbZFIJNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 05:13:47 -0400
In-Reply-To: <20090609.013718.135786197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The smsc911x driver should build fine on any system as it contains no arch
specific code (all platform resources), and any platform that has
appropriate resources should run fine.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
v3
	- based on net-next

 drivers/net/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 962b261..8c92abd 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1000,7 +1000,6 @@ config SMC911X
 
 config SMSC911X
 	tristate "SMSC LAN911x/LAN921x families embedded ethernet support"
-	depends on ARM || SUPERH || BLACKFIN
 	select CRC32
 	select MII
 	select PHYLIB
-- 
1.6.3.1

