From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH] [net] gianfar: remove orphan struct.
Date: Wed, 17 Oct 2007 10:52:22 +0200
Message-ID: <E1Ii4k6-0000VM-0j@Chamillionaire.breakpoint.cc>
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:51522 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753234AbXJQI7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 04:59:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct net_device_stats is no longer used in driver's private
struct but in struct net_device.

Cc: Li Yang <leoli@freescale.com>
Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
---
 drivers/net/gianfar.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index c16cc8b..46cd773 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -749,7 +749,6 @@ struct gfar_private {
 	uint32_t msg_enable;
 
 	/* Network Statistics */
-	struct net_device_stats stats;
 	struct gfar_extra_stats extra_stats;
 };
 
-- 
1.5.2.2

