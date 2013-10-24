From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH RFC v2 4/4] net: mvmdio: doc: mvmdio now used by mv643xx_eth
Date: Thu, 24 Oct 2013 19:09:34 +0100
Message-ID: <3a4501026bcdf137b459ec5dc19363b8b86fc8ef.1382637156.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, sebastian.hesselbarth@gmail.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:51345 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab3JXSKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 14:10:10 -0400
In-Reply-To: <cover.1382637156.git.leigh@solinno.co.uk>
In-Reply-To: <cover.1382637156.git.leigh@solinno.co.uk>
References: <cover.1382199042.git.leigh@solinno.co.uk> <cover.1382637156.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amend the documentation in the mvmdio driver to note the fact
that it is now used by both the mvneta and mv643xx_eth drivers.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>
---
 drivers/net/ethernet/marvell/mvmdio.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 13f4614..79b6d32 100644
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
1.7.10.4
