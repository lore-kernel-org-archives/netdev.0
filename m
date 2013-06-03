From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: emaclite: include linux/of_irq.h
Date: Mon, 03 Jun 2013 23:39:29 +0200
Message-ID: <2244203.EL457oABTU@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54156 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab3FCVjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 17:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The emaclite driver now calls of_irq_to_resource, which is
declared in linux/of_irq.h. Without this patch, I get a build
error on ARM.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Michal Simek <michal.simek@xilinx.com>

diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index aa14d8a..9559a3d 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -22,6 +22,7 @@
 #include <linux/slab.h>
 #include <linux/of_address.h>
 #include <linux/of_device.h>
+#include <linux/of_irq.h>
 #include <linux/of_platform.h>
 #include <linux/of_mdio.h>
 #include <linux/of_net.h>
