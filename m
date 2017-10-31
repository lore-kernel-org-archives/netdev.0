From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: phy: Fix sfp.c build against GPIO definitions
Date: Mon, 30 Oct 2017 21:42:58 -0700
Message-ID: <20171031044258.16094-3-f.fainelli@gmail.com>
References: <20171031044258.16094-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, rmk+kernel@armlinux.org.uk, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:47451 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752457AbdJaEnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 00:43:07 -0400
Received: by mail-oi0-f68.google.com with SMTP id h200so25456481oib.4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 21:43:07 -0700 (PDT)
In-Reply-To: <20171031044258.16094-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

include/gpio.h does not contain the references we want, we should be including
linux/gpio/consumer.h instead.

Fixes: 73970055450e ("sfp: add SFP module support")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/sfp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/sfp.c b/drivers/net/phy/sfp.c
index 448465da0422..e381811e5f11 100644
--- a/drivers/net/phy/sfp.c
+++ b/drivers/net/phy/sfp.c
@@ -1,5 +1,5 @@
 #include <linux/delay.h>
-#include <linux/gpio.h>
+#include <linux/gpio/consumer.h>
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/jiffies.h>
-- 
2.14.1
