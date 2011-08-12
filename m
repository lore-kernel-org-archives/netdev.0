From: Robin Holt <holt@sgi.com>
Subject: [PATCH v12 1/6] flexcan: Remove #include <mach/clock.h>
Date: Fri, 12 Aug 2011 03:45:47 -0500
Message-ID: <1313138752-24006-2-git-send-email-holt@sgi.com>
References: <1313138752-24006-1-git-send-email-holt@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	PPC list <linuxppc-dev@lists.ozlabs.org>
To: Robin Holt <holt@sgi.com>, Kumar Gala <galak@kernel.crashing.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:53040 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751980Ab1HLIqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 04:46:10 -0400
In-Reply-To: <1313138752-24006-1-git-send-email-holt@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

powerpc does not have a mach-####/clock.h.  When testing, I found neither
arm nor powerpc needed the mach/clock.h at all so I removed it.

Signed-off-by: Robin Holt <holt@sgi.com>
Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Cc: U Bhaskar-B22300 <B22300@freescale.com>
Cc: socketcan-core@lists.berlios.de
Cc: netdev@vger.kernel.org
Cc: PPC list <linuxppc-dev@lists.ozlabs.org>
---
 drivers/net/can/flexcan.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index 1767811..586b2cd 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -35,8 +35,6 @@
 #include <linux/module.h>
 #include <linux/platform_device.h>
 
-#include <mach/clock.h>
-
 #define DRV_NAME			"flexcan"
 
 /* 8 for RX fifo and 2 error handling */
-- 
1.7.2.1

