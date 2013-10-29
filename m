From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH v3 4/4] net: mvmdio: doc: mvmdio now used by mv643xx_eth
Date: Tue, 29 Oct 2013 09:33:34 +0000
Message-ID: <391dec8a6a1b3c9a19f83eabb04e628da12c86ba.1383038974.git.leigh@solinno.co.uk>
References: <cover.1383038973.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:58168 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab3J2JeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:34:02 -0400
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1383038973.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk> <cover.1383038973.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amend the documentation in the mvmdio driver to note the fact
that it is now used by both the mvneta and mv643xx_eth drivers.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 0cfa0c8..0d0311c 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -4,11 +4,9 @@
  * Since the MDIO interface of Marvell network interfaces is shared
  * between all network interfaces, having a single driver allows to
  * handle concurrent accesses properly (you may have four Ethernet
- * ports, but they in fact share the same SMI interface to access the
- * MDIO bus). Moreover, this MDIO interface code is similar between
- * the mv643xx_eth driver and the mvneta driver. For now, it is only
- * used by the mvneta driver, but it could later be used by the
- * mv643xx_eth driver as well.
+ * ports, but they in fact share the same SMI interface to access
+ * the MDIO bus). This driver is currently used by the mvneta and 
+ * mv643xx_eth drivers.
  *
  * Copyright (C) 2012 Marvell
  *
-- 
1.8.4.rc3
