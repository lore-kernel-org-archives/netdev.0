From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] cxgb3: Restore dependency on INET
Date: Wed, 28 Nov 2012 20:03:03 +0000
Message-ID: <1354132983.2768.1.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Fengguang Wu <fengguang.wu@intel.com>,
	Divy Le Ray <divy@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19768 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096Ab2K1UDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 15:03:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ff33c0e1885cda44dd14c79f70df4706f83582a0 ('net: Remove bogus
dependencies on INET') wrongly removed this dependency.  cxgb3 uses
the arp_send() function defined in net/ipv4/arp.c.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/chelsio/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index a71c0f3..d40c994 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -48,7 +48,7 @@ config CHELSIO_T1_1G
 
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on PCI
+	depends on PCI && INET
 	select FW_LOADER
 	select MDIO
 	---help---
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
