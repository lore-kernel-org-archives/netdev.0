From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/2] net: mdio-gpio: move platform data header
Date: Tue, 20 Oct 2015 10:08:59 -0400
Message-ID: <1445350139-2527-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1445350139-2527-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33590 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbbJTOR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 10:17:28 -0400
In-Reply-To: <1445350139-2527-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This header file only contains the platform data structure definition,
so move it to the include/linux/platform_data/ directory.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/phy/mdio-gpio.c                   | 2 +-
 include/linux/{ => platform_data}/mdio-gpio.h | 0
 2 files changed, 1 insertion(+), 1 deletion(-)
 rename include/linux/{ => platform_data}/mdio-gpio.h (100%)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 3bc9f03..95f51d7 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -25,7 +25,7 @@
 #include <linux/interrupt.h>
 #include <linux/platform_device.h>
 #include <linux/gpio.h>
-#include <linux/mdio-gpio.h>
+#include <linux/platform_data/mdio-gpio.h>
 
 #include <linux/of_gpio.h>
 #include <linux/of_mdio.h>
diff --git a/include/linux/mdio-gpio.h b/include/linux/platform_data/mdio-gpio.h
similarity index 100%
rename from include/linux/mdio-gpio.h
rename to include/linux/platform_data/mdio-gpio.h
-- 
2.6.1
