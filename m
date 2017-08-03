From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next v2 1/7] net: mvpp2: fix MVPP21_ISR_RXQ_GROUP_REG definition
Date: Thu,  3 Aug 2017 10:41:55 +0200
Message-ID: <20170803084201.30305-2-thomas.petazzoni@free-electrons.com>
References: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:46628 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbdHCIm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 04:42:28 -0400
In-Reply-To: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MVPP21_ISR_RXQ_GROUP_REG register is not indexed by rxq, but by
port, so we fix the parameter name accordingly. There are no
functional changes.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 48d21c1..4b36a15 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -185,7 +185,7 @@
 /* Interrupt Cause and Mask registers */
 #define MVPP2_ISR_RX_THRESHOLD_REG(rxq)		(0x5200 + 4 * (rxq))
 #define     MVPP2_MAX_ISR_RX_THRESHOLD		0xfffff0
-#define MVPP21_ISR_RXQ_GROUP_REG(rxq)		(0x5400 + 4 * (rxq))
+#define MVPP21_ISR_RXQ_GROUP_REG(port)		(0x5400 + 4 * (port))
 
 #define MVPP22_ISR_RXQ_GROUP_INDEX_REG          0x5400
 #define MVPP22_ISR_RXQ_GROUP_INDEX_SUBGROUP_MASK 0xf
-- 
2.9.4
