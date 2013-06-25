From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH v2 3/7] alx: remove NET_CORE Kconfig select
Date: Tue, 25 Jun 2013 20:38:19 +0200
Message-ID: <1372185503-24705-4-git-send-email-johannes@sipsolutions.net>
References: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:41273 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752186Ab3FYSi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 14:38:29 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1UrY8K-0003om-EP
	for netdev@vger.kernel.org; Tue, 25 Jun 2013 20:38:28 +0200
In-Reply-To: <1372185503-24705-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That select doesn't make any sense, remove it.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 drivers/net/ethernet/atheros/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/Kconfig b/drivers/net/ethernet/atheros/Kconfig
index ad6aa1e9..802f6a3 100644
--- a/drivers/net/ethernet/atheros/Kconfig
+++ b/drivers/net/ethernet/atheros/Kconfig
@@ -71,7 +71,6 @@ config ALX
 	tristate "Qualcomm Atheros AR816x/AR817x support"
 	depends on PCI
 	select CRC32
-	select NET_CORE
 	select MDIO
 	help
 	  This driver supports the Qualcomm Atheros L1F ethernet adapter,
-- 
1.8.0
