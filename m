From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH net-next 1/7] net:fec: remove unnecessary ip stack includes
Date: Tue, 29 Apr 2014 20:09:04 +0800
Message-ID: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0142.outbound.protection.outlook.com ([207.46.163.142]:10946
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751330AbaD2Nes (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 09:34:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

Commit 4c09eed9dc42 (net: fec: Enable imx6 enet checksum acceleration.)
added support for hardware checksum support, adding six new includes
for things like tcp, udp, ip, icmp, but never made use of anything
provided by those header files.  Let's remove this bloat.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 8d69e43..b151eaf 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -33,12 +33,6 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/in.h>
-#include <linux/ip.h>
-#include <net/ip.h>
-#include <linux/tcp.h>
-#include <linux/udp.h>
-#include <linux/icmp.h>
 #include <linux/spinlock.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
-- 
1.7.8
