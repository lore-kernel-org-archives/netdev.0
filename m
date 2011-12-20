From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] net: macb: fix build break with !CONFIG_OF
Date: Tue, 20 Dec 2011 13:20:29 -0800
Message-ID: <1324416029-28198-1-git-send-email-olof@lixom.net>
Cc: netdev@vger.kernel.org,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Jamie Iles <jamie@jamieiles.com>,
	linux-arm-kernel@lists.infradead.org,
	Olof Johansson <olof@lixom.net>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:45605 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752295Ab1LTVZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 16:25:05 -0500
Received: by iaeh11 with SMTP id h11so10790167iae.19
        for <netdev@vger.kernel.org>; Tue, 20 Dec 2011 13:25:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the build of the macb driver that was broken by the DT changes:

drivers/net/ethernet/cadence/macb.c:1503: error: implicit declaration of function 'of_match_ptr'
drivers/net/ethernet/cadence/macb.c:1503: error: 'macb_dt_ids' undeclared here (not in a function)
drivers/net/ethernet/cadence/macb.c:1503: error: initializer element is not constant
drivers/net/ethernet/cadence/macb.c:1503: error: (near initialization for 'macb_driver.driver.of_match_table')

Signed-off-by: Olof Johansson <olof@lixom.net>
---

Nicolas, care to ack this so I can apply it on top of the macb DT branch in arm-soc?

 drivers/net/ethernet/cadence/macb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index baf1a0d..f3d5c65 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -23,6 +23,7 @@
 #include <linux/platform_data/macb.h>
 #include <linux/platform_device.h>
 #include <linux/phy.h>
+#include <linux/of.h>
 #include <linux/of_device.h>
 #include <linux/of_net.h>
 
-- 
1.7.5.4
