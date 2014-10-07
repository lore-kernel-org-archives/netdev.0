From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 4/8] gianfar: Include missing headers for ARM builds
Date: Tue, 7 Oct 2014 10:44:31 +0300
Message-ID: <1412667875-18225-5-git-send-email-claudiu.manoil@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.169.139] ([65.55.169.139]:31859 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753165AbaJGHrm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:42 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include linux/of_address.h for of_iomap() and linux/of_irq.h
for irq_of_parse_and_map().

This wasn't an issue for PPC, because these were implicitly
included from asm/prom.h (via linux/of.h) for PPC builds only.
ARM builds need these includes explicitly.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2 - none

 drivers/net/ethernet/freescale/gianfar.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index fb29d04..a488105 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -100,6 +100,8 @@
 #include <linux/phy_fixed.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
 
 #include "gianfar.h"
 
-- 
1.7.11.7
