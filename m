From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/3] net: dsa: mv88e6xxx: fix module naming
Date: Fri,  2 Sep 2016 08:08:17 -0400
Message-ID: <20160902120819.10773-2-vivien.didelot@savoirfairelinux.com>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:33445 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752419AbcIBMIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 08:08:43 -0400
In-Reply-To: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the mv88e6xxx.c file has been renamed, the driver compiled as a
module is called chip.ko instead of mv88e6xxx.ko. Fix this.

Fixes: fad09c73c270 ("net: dsa: mv88e6xxx: rename single-chip support")
Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 6e29a75..e58b745 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -1 +1,2 @@
-obj-$(CONFIG_NET_DSA_MV88E6XXX) += chip.o
+obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
+mv88e6xxx-objs := chip.o
-- 
2.9.3
