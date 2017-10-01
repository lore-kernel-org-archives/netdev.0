From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: [PATCH 6/6] bcm63xx_enet: remove unneeded include
Date: Sun,  1 Oct 2017 13:02:20 +0200
Message-ID: <20171001110220.27668-7-jonas.gorski@gmail.com>
References: <20171001110220.27668-1-jonas.gorski@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36734 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751005AbdJALCT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Oct 2017 07:02:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id 63so678550wmn.3
        for <netdev@vger.kernel.org>; Sun, 01 Oct 2017 04:02:18 -0700 (PDT)
In-Reply-To: <20171001110220.27668-1-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't use anyhing from that file, so drop it.

Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.h b/drivers/net/ethernet/broadcom/bcm63xx_enet.h
index 0a1b7b2e55bd..dd6ae3077433 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.h
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.h
@@ -8,7 +8,6 @@
 #include <linux/platform_device.h>
 
 #include <bcm63xx_regs.h>
-#include <bcm63xx_irq.h>
 #include <bcm63xx_io.h>
 #include <bcm63xx_iudma.h>
 
-- 
2.13.2
