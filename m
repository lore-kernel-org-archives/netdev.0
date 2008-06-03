From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 08/39] mv643xx_eth: nuke port status register bit defines
Date: Tue,  3 Jun 2008 13:02:23 +0200
Message-ID: <1212490974-23719-9-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48742 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753010AbYFCMAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:25 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of the port status register bit defines are ever used in the
mv643xx_eth driver -- nuke them all.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   14 --------------
 1 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index e4f0189..4b61acc 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -150,20 +150,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define FORCE_LINK_PASS				(1 << 1)
 #define SERIAL_PORT_ENABLE			(1 << 0)
 
-/* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define PORT_STATUS_MODE_10_BIT		(1 << 0)
-#define PORT_STATUS_LINK_UP		(1 << 1)
-#define PORT_STATUS_FULL_DUPLEX		(1 << 2)
-#define PORT_STATUS_FLOW_CONTROL	(1 << 3)
-#define PORT_STATUS_GMII_1000		(1 << 4)
-#define PORT_STATUS_MII_100		(1 << 5)
-/* PSR bit 6 is undocumented */
-#define PORT_STATUS_TX_IN_PROGRESS	(1 << 7)
-#define PORT_STATUS_AUTONEG_BYPASSED	(1 << 8)
-#define PORT_STATUS_PARTITION		(1 << 9)
-#define PORT_STATUS_TX_FIFO_EMPTY	(1 << 10)
-/* PSR bits 11-31 are reserved */
-
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-- 
1.5.3.4

