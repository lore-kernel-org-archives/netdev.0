From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 07/11] net: mvpp2: remove unused register definitions
Date: Wed, 28 Dec 2016 17:46:03 +0100
Message-ID: <1482943567-12483-8-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47561 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751842AbcL1QqZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:46:25 -0500
In-Reply-To: <1482943567-12483-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 8174f40..edffcc1 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -253,10 +253,6 @@
 #define MVPP2_SRC_ADDR_HIGH			0x28
 #define MVPP2_PHY_AN_CFG0_REG			0x34
 #define     MVPP2_PHY_AN_STOP_SMI0_MASK		BIT(7)
-#define MVPP2_MIB_COUNTERS_BASE(port)		(0x1000 + ((port) >> 1) * \
-						0x400 + (port) * 0x400)
-#define     MVPP2_MIB_LATE_COLLISION		0x7c
-#define MVPP2_ISR_SUM_MASK_REG			0x220c
 #define MVPP2_MNG_EXTENDED_GLOBAL_CTRL_REG	0x305c
 #define MVPP2_EXT_GLOBAL_CTRL_DEFAULT		0x27
 
-- 
2.7.4
