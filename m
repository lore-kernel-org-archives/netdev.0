From: Andreas Schwab <schwab@suse.de>
Subject: [PATCH] net: cavium: change NET_VENDOR_CAVIUM to bool
Date: Mon, 19 Oct 2015 17:37:13 +0200
Message-ID: <mvmy4eyq386.fsf@hawking.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35421 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753964AbbJSPhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 11:37:14 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id A1E1EAB1A
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 15:37:12 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_NET_VENDOR_CAVIUM is only used to hide/show config options and to
include subdirectories in the build, so it doesn't make sense to make it
tristate.

Signed-off-by: Andreas Schwab <schwab@suse.de>
---
 drivers/net/ethernet/cavium/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 9b35d14..8fb84e6 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config NET_VENDOR_CAVIUM
-	tristate "Cavium ethernet drivers"
+	bool "Cavium ethernet drivers"
 	depends on PCI
 	default y
 	---help---
-- 
2.6.2


-- 
Andreas Schwab, SUSE Labs, schwab@suse.de
GPG Key fingerprint = 0196 BAD8 1CE9 1970 F4BE  1748 E4D4 88E3 0EEA B9D7
"And now for something completely different."
