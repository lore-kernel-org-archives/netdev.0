From: Abhimanyu <abhimanyu@freescale.com>
Subject: [PATCH net-next] gianfar: Increase TX_TIMEOUT to 5HZ
Date: Tue, 27 Oct 2015 14:17:43 +0530
Message-ID: <1445935663-15117-1-git-send-email-abhimanyu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <claudiu.manoil@freescale.com>,
	Abhimanyu <abhimanyu@freescale.com>,
	Priyanka Jain <Priyanka.Jain@freescale.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0119.outbound.protection.outlook.com ([157.56.110.119]:35328
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754709AbbJ0JDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 05:03:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Increased TX_TIMEOUT to 5HZ to accommodate worst case situation
for traffic and CPU intensive use cases

Signed-off-by: Priyanka Jain <Priyanka.Jain@freescale.com>
Signed-off-by: Abhimanyu <abhimanyu@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 7f5389c..47f0400 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -107,7 +107,7 @@
 
 #include "gianfar.h"
 
-#define TX_TIMEOUT      (1*HZ)
+#define TX_TIMEOUT      (5*HZ)
 
 const char gfar_driver_version[] = "2.0";
 
-- 
1.7.7.4
