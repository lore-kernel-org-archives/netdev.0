From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v3 net 2/6] net: mvneta: fix bit assignment in MVNETA_RXQ_CONFIG_REG
Date: Fri, 27 Nov 2015 16:44:22 +0100
Message-ID: <1448639066-13074-3-git-send-email-mw@semihalf.com>
References: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:33832 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754965AbbK0Poi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 10:44:38 -0500
Received: by lffu14 with SMTP id u14so133790307lff.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 07:44:35 -0800 (PST)
In-Reply-To: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MVNETA_RXQ_HW_BUF_ALLOC bit which controls enabling hardware buffer
allocation was mistakenly set as BIT(1). This commit fixes the assignment.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Reviewed-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network
unit")
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 2d80256..64c46f0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -36,7 +36,7 @@
 
 /* Registers */
 #define MVNETA_RXQ_CONFIG_REG(q)                (0x1400 + ((q) << 2))
-#define      MVNETA_RXQ_HW_BUF_ALLOC            BIT(1)
+#define      MVNETA_RXQ_HW_BUF_ALLOC            BIT(0)
 #define      MVNETA_RXQ_PKT_OFFSET_ALL_MASK     (0xf    << 8)
 #define      MVNETA_RXQ_PKT_OFFSET_MASK(offs)   ((offs) << 8)
 #define MVNETA_RXQ_THRESHOLD_REG(q)             (0x14c0 + ((q) << 2))
-- 
1.8.3.1
