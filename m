From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: mvneta: Remove unneeded version.h header inclusion
Date: Mon,  3 Dec 2012 15:15:28 +0530
Message-ID: <1354527928-27472-1-git-send-email-sachin.kamat@linaro.org>
Cc: thomas.petazzoni@free-electrons.com, sachin.kamat@linaro.org,
	patches@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:33665 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382Ab2LCJwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 04:52:12 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so1882981pbc.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 01:52:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

linux/version.h inclusion is not necessary.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/marvell/mvneta.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 3f8086b..a1e0e9f 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -12,7 +12,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
-- 
1.7.4.1
