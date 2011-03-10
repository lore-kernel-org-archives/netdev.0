From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH] xen: netfront: ethtool stats fields should be unsigned long
Date: Thu, 10 Mar 2011 17:04:18 +0000
Message-ID: <1299776658-15137-1-git-send-email-ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:60878 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751252Ab1CJREX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2011 12:04:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixup the rx_gso_checksum_fixup field added in e0ce4af920eb to be
unsigned long as suggested by Ben Hutchings in
<1298919198.2569.14.camel@bwh-desktop>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a6ab973..df45323 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -122,7 +122,7 @@ struct netfront_info {
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
 
 	/* Statistics */
-	int rx_gso_checksum_fixup;
+	unsigned long rx_gso_checksum_fixup;
 };
 
 struct netfront_rx_info {
-- 
1.5.6.5

