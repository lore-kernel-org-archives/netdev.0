From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 2/2] ucc_geth: Initialize mdio_lock.
Date: Thu, 7 Dec 2006 13:31:26 -0600
Message-ID: <20061207193126.GB23994@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:47783 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S938000AbWLGTcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 14:32:22 -0500
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/ucc_geth.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 62d979b..8243150 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1852,6 +1852,8 @@ static int init_phy(struct net_device *d
 	mii_info->mdio_read = &read_phy_reg;
 	mii_info->mdio_write = &write_phy_reg;
 
+	spin_lock_init(&mii_info->mdio_lock);
+
 	ugeth->mii_info = mii_info;
 
 	spin_lock_irq(&ugeth->lock);
-- 
1.4.2.3

