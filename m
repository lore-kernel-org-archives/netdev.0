From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/5] sfc: Minor formatting cleanup
Date: Thu, 23 Feb 2012 17:41:27 +0000
Message-ID: <1330018887.2511.5.camel@bwh-desktop>
References: <1330018734.2511.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7296 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752207Ab2BWRla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 12:41:30 -0500
In-Reply-To: <1330018734.2511.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix some indentation and line continuations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h |    4 ++--
 drivers/net/ethernet/sfc/mcdi_mon.c |    2 +-
 drivers/net/ethernet/sfc/tx.c       |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index a2a9f40..b26a954 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -531,8 +531,8 @@ typedef union efx_oword {
 

 /* Static initialiser */
-#define EFX_OWORD32(a, b, c, d)						\
-	{ .u32 = { cpu_to_le32(a), cpu_to_le32(b), \
+#define EFX_OWORD32(a, b, c, d)				\
+	{ .u32 = { cpu_to_le32(a), cpu_to_le32(b),	\
 		   cpu_to_le32(c), cpu_to_le32(d) } }
 
 #endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
index 8a72c10..fb7f65b 100644
--- a/drivers/net/ethernet/sfc/mcdi_mon.c
+++ b/drivers/net/ethernet/sfc/mcdi_mon.c
@@ -37,7 +37,7 @@ static const struct {
 	SENSOR(PHY0_TEMP,	   "PHY temp.",		   EFX_HWMON_TEMP, 0),
 	SENSOR(PHY0_COOLING,	   "PHY cooling",	   EFX_HWMON_COOL, 0),
 	SENSOR(PHY1_TEMP,	   "PHY temp.",		   EFX_HWMON_TEMP, 1),
-	SENSOR(PHY1_COOLING, 	   "PHY cooling",	   EFX_HWMON_COOL, 1),
+	SENSOR(PHY1_COOLING,	   "PHY cooling",	   EFX_HWMON_COOL, 1),
 	SENSOR(IN_1V0,		   "1.0V supply",	   EFX_HWMON_IN,   -1),
 	SENSOR(IN_1V2,		   "1.2V supply",	   EFX_HWMON_IN,   -1),
 	SENSOR(IN_1V8,		   "1.8V supply",	   EFX_HWMON_IN,   -1),
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index a096e28..94d0365 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -339,7 +339,7 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
  * OS to free the skb.
  */
 netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
-				      struct net_device *net_dev)
+				struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_tx_queue *tx_queue;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
