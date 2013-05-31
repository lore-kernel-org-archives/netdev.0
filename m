From: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Subject: [PATCH] net: emaclite: Fix typo in error message
Date: Fri, 31 May 2013 12:30:14 +0200
Message-ID: <51A87BB6.7060207@efe-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <monstr@monstr.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:62079 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753058Ab3EaK37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 06:29:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

s/allocal/allocate/

Signed-off-by: Jens Renner <renner@efe-gmbh.de>
---
drivers/net/ethernet/xilinx/xilinx_emaclite.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index aa14d8a..aaadf7e 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -877,7 +877,7 @@ static int xemaclite_mdio_setup(struct net_local *lp, struct device *dev)

        bus = mdiobus_alloc();
        if (!bus) {
-               dev_err(dev, "Failed to allocal mdiobus\n");
+               dev_err(dev, "Failed to allocate mdiobus\n");
                return -ENOMEM;
        }
