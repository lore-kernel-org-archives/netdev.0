From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 1/2] fec: Remove unused pci header
Date: Mon, 11 Mar 2013 14:32:54 -0300
Message-ID: <1363023175-17597-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <s.hauer@pengutronix.de>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:58913 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753530Ab3CKReR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 13:34:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI header is not needed, so get rid of it.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 069a155..89c27e6 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -29,7 +29,6 @@
 #include <linux/ioport.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
-#include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-- 
1.7.9.5
