From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 10/10] sfc: Do not include unneeded headers
Date: Wed, 03 Feb 2010 19:32:06 +0000
Message-ID: <1265225526.2116.10.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28146 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757619Ab0BCTcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:32:09 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier refactoring has made these inclusions unnecessary.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    1 -
 drivers/net/sfc/selftest.c   |    2 --
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ac77a25..cb018e2 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -18,7 +18,6 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
-#include <linux/timer.h>
 #include <linux/mdio.h>
 #include <linux/list.h>
 #include <linux/pci.h>
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 8a5a7b6..cf0139a 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -24,8 +24,6 @@
 #include "nic.h"
 #include "selftest.h"
 #include "workarounds.h"
-#include "spi.h"
-#include "io.h"
 
 /*
  * Loopback test packet structure
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

