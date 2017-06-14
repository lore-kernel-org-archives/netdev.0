From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v4 02/11] net: mvmdio: use tabs for defines
Date: Wed, 14 Jun 2017 17:49:02 +0200
Message-ID: <20170614154911.14510-3-antoine.tenart@free-electrons.com>
References: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:34944 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752515AbdFNPy1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 11:54:27 -0400
In-Reply-To: <20170614154911.14510-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cosmetic patch replacing spaces by tabs for defined values.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/marvell/mvmdio.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 109a2bff334d..17b518b13ae3 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -30,25 +30,25 @@
 #include <linux/sched.h>
 #include <linux/wait.h>
 
-#define MVMDIO_SMI_DATA_SHIFT              0
-#define MVMDIO_SMI_PHY_ADDR_SHIFT          16
-#define MVMDIO_SMI_PHY_REG_SHIFT           21
-#define MVMDIO_SMI_READ_OPERATION          BIT(26)
-#define MVMDIO_SMI_WRITE_OPERATION         0
-#define MVMDIO_SMI_READ_VALID              BIT(27)
-#define MVMDIO_SMI_BUSY                    BIT(28)
-#define MVMDIO_ERR_INT_CAUSE		   0x007C
-#define  MVMDIO_ERR_INT_SMI_DONE	   0x00000010
-#define MVMDIO_ERR_INT_MASK		   0x0080
+#define MVMDIO_SMI_DATA_SHIFT		0
+#define MVMDIO_SMI_PHY_ADDR_SHIFT	16
+#define MVMDIO_SMI_PHY_REG_SHIFT	21
+#define MVMDIO_SMI_READ_OPERATION	BIT(26)
+#define MVMDIO_SMI_WRITE_OPERATION	0
+#define MVMDIO_SMI_READ_VALID		BIT(27)
+#define MVMDIO_SMI_BUSY			BIT(28)
+#define MVMDIO_ERR_INT_CAUSE		0x007C
+#define  MVMDIO_ERR_INT_SMI_DONE	0x00000010
+#define MVMDIO_ERR_INT_MASK		0x0080
 
 /*
  * SMI Timeout measurements:
  * - Kirkwood 88F6281 (Globalscale Dreamplug): 45us to 95us (Interrupt)
  * - Armada 370       (Globalscale Mirabox):   41us to 43us (Polled)
  */
-#define MVMDIO_SMI_TIMEOUT		   1000 /* 1000us = 1ms */
-#define MVMDIO_SMI_POLL_INTERVAL_MIN	   45
-#define MVMDIO_SMI_POLL_INTERVAL_MAX	   55
+#define MVMDIO_SMI_TIMEOUT		1000 /* 1000us = 1ms */
+#define MVMDIO_SMI_POLL_INTERVAL_MIN	45
+#define MVMDIO_SMI_POLL_INTERVAL_MAX	55
 
 struct orion_mdio_dev {
 	struct mutex lock;
-- 
2.9.4
