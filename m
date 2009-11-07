From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 01/75] netx: declare MODULE_FIRMWARE
Date: Sat, 07 Nov 2009 21:37:36 +0000
Message-ID: <1257629856.15927.370.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Sascha Hauer <s.hauer@pengutronix.de>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33531 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752048AbZKGVhh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2009 16:37:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Note that the filenames are generated in xc_request_firmware(), defined
in arch/arm/mach-netx/xc.c.  I'm not sure whether it's actually worth
doing this for a platform driver.

Ben.

 drivers/net/netx-eth.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 9f42354..a0d65f5 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -510,3 +510,6 @@ module_exit(netx_eth_cleanup);
 MODULE_AUTHOR("Sascha Hauer, Pengutronix");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:" CARDNAME);
+MODULE_FIRMWARE("xc0.bin");
+MODULE_FIRMWARE("xc1.bin");
+MODULE_FIRMWARE("xc2.bin");
-- 
1.6.5.2



