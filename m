From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] net/faraday: Explicitly include linux/of.h and linux/property.h
Date: Thu, 30 Mar 2017 17:00:12 +0100
Message-ID: <20170330160012.14824-1-broonie@kernel.org>
Cc: netdev@vger.kernel.org, Mark Brown <broonie@kernel.org>
To: "David S . Miller" <davem@davemloft.net>,
        Joel Stanley <joel@jms.id.au>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:40766 "EHLO
        mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933464AbdC3QAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:00:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver uses interfaces from linux/of.h and linux/property.h but
relies on implict inclusion of those headers which means that changes in
other headers could break the build, as happened in -next for arm today.
Add a explicit includes.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 928b0df2b8e0..ade6b3e4ed13 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -28,8 +28,10 @@
 #include <linux/io.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/of.h>
 #include <linux/phy.h>
 #include <linux/platform_device.h>
+#include <linux/property.h>
 #include <net/ip.h>
 #include <net/ncsi.h>
 
-- 
2.11.0
