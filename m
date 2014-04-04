From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: bcmgenet: Remove unnecessary version.h inclusion
Date: Fri,  4 Apr 2014 11:43:35 +0530
Message-ID: <1396592015-19123-1-git-send-email-sachin.kamat@linaro.org>
Cc: f.fainelli@gmail.com, davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:52908 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbaDDGOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 02:14:03 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so2991557pbc.30
        for <netdev@vger.kernel.org>; Thu, 03 Apr 2014 23:14:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

version.h inclusion is not necessary as detected by versioncheck.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index adf8acbddf56..0966bd04375f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -34,7 +34,6 @@
 #include <linux/dma-mapping.h>
 #include <linux/pm.h>
 #include <linux/clk.h>
-#include <linux/version.h>
 #include <linux/of.h>
 #include <linux/of_address.h>
 #include <linux/of_irq.h>
-- 
1.7.9.5
