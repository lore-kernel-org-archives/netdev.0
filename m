From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/16] sfc: Define and use
 MCDI_POPULATE_DWORD_{1,2,3,4,5,6,7}
Date: Tue, 27 Aug 2013 21:49:58 +0100
Message-ID: <1377636598.13272.87.camel@bwh-desktop.uk.level5networks.com>
References: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6173 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab3H0UuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 16:50:01 -0400
In-Reply-To: <1377635844.13272.69.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is only one user now, but we're about to add many more.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.h      | 54 ++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/mcdi_port.c | 18 ++++++------
 2 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 69586e0..a465cc1 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -128,6 +128,60 @@ extern void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
 	EFX_POPULATE_DWORD_1(*_MCDI_DWORD(_buf, _field), EFX_DWORD_0, _value)
 #define MCDI_DWORD(_buf, _field)					\
 	EFX_DWORD_FIELD(*_MCDI_DWORD(_buf, _field), EFX_DWORD_0)
+#define MCDI_POPULATE_DWORD_1(_buf, _field, _name1, _value1)		\
+	EFX_POPULATE_DWORD_1(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1)
+#define MCDI_POPULATE_DWORD_2(_buf, _field, _name1, _value1,		\
+			      _name2, _value2)				\
+	EFX_POPULATE_DWORD_2(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1,		\
+			     MC_CMD_ ## _name2, _value2)
+#define MCDI_POPULATE_DWORD_3(_buf, _field, _name1, _value1,		\
+			      _name2, _value2, _name3, _value3)		\
+	EFX_POPULATE_DWORD_3(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1,		\
+			     MC_CMD_ ## _name2, _value2,		\
+			     MC_CMD_ ## _name3, _value3)
+#define MCDI_POPULATE_DWORD_4(_buf, _field, _name1, _value1,		\
+			      _name2, _value2, _name3, _value3,		\
+			      _name4, _value4)				\
+	EFX_POPULATE_DWORD_4(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1,		\
+			     MC_CMD_ ## _name2, _value2,		\
+			     MC_CMD_ ## _name3, _value3,		\
+			     MC_CMD_ ## _name4, _value4)
+#define MCDI_POPULATE_DWORD_5(_buf, _field, _name1, _value1,		\
+			      _name2, _value2, _name3, _value3,		\
+			      _name4, _value4, _name5, _value5)		\
+	EFX_POPULATE_DWORD_5(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1,		\
+			     MC_CMD_ ## _name2, _value2,		\
+			     MC_CMD_ ## _name3, _value3,		\
+			     MC_CMD_ ## _name4, _value4,		\
+			     MC_CMD_ ## _name5, _value5)
+#define MCDI_POPULATE_DWORD_6(_buf, _field, _name1, _value1,		\
+			      _name2, _value2, _name3, _value3,		\
+			      _name4, _value4, _name5, _value5,		\
+			      _name6, _value6)				\
+	EFX_POPULATE_DWORD_6(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1,		\
+			     MC_CMD_ ## _name2, _value2,		\
+			     MC_CMD_ ## _name3, _value3,		\
+			     MC_CMD_ ## _name4, _value4,		\
+			     MC_CMD_ ## _name5, _value5,		\
+			     MC_CMD_ ## _name6, _value6)
+#define MCDI_POPULATE_DWORD_7(_buf, _field, _name1, _value1,		\
+			      _name2, _value2, _name3, _value3,		\
+			      _name4, _value4, _name5, _value5,		\
+			      _name6, _value6, _name7, _value7)		\
+	EFX_POPULATE_DWORD_7(*_MCDI_DWORD(_buf, _field),		\
+			     MC_CMD_ ## _name1, _value1,		\
+			     MC_CMD_ ## _name2, _value2,		\
+			     MC_CMD_ ## _name3, _value3,		\
+			     MC_CMD_ ## _name4, _value4,		\
+			     MC_CMD_ ## _name5, _value5,		\
+			     MC_CMD_ ## _name6, _value6,		\
+			     MC_CMD_ ## _name7, _value7)
 #define MCDI_SET_QWORD(_buf, _field, _value)				\
 	do {								\
 		EFX_POPULATE_DWORD_1(_MCDI_DWORD(_buf, _field)[0],	\
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index e359227..30e8a19 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -926,21 +926,19 @@ static int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_MAC_STATS_IN_LEN);
 	int rc;
-	efx_dword_t *cmd_ptr;
 	int period = enable ? 1000 : 0;
 
 	BUILD_BUG_ON(MC_CMD_MAC_STATS_OUT_DMA_LEN != 0);
 
 	MCDI_SET_QWORD(inbuf, MAC_STATS_IN_DMA_ADDR, dma_addr);
-	cmd_ptr = (efx_dword_t *)MCDI_PTR(inbuf, MAC_STATS_IN_CMD);
-	EFX_POPULATE_DWORD_7(*cmd_ptr,
-			     MC_CMD_MAC_STATS_IN_DMA, !!enable,
-			     MC_CMD_MAC_STATS_IN_CLEAR, clear,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_CHANGE, 1,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_ENABLE, !!enable,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_CLEAR, 0,
-			     MC_CMD_MAC_STATS_IN_PERIODIC_NOEVENT, 1,
-			     MC_CMD_MAC_STATS_IN_PERIOD_MS, period);
+	MCDI_POPULATE_DWORD_7(inbuf, MAC_STATS_IN_CMD,
+			      MAC_STATS_IN_DMA, !!enable,
+			      MAC_STATS_IN_CLEAR, clear,
+			      MAC_STATS_IN_PERIODIC_CHANGE, 1,
+			      MAC_STATS_IN_PERIODIC_ENABLE, !!enable,
+			      MAC_STATS_IN_PERIODIC_CLEAR, 0,
+			      MAC_STATS_IN_PERIODIC_NOEVENT, 1,
+			      MAC_STATS_IN_PERIOD_MS, period);
 	MCDI_SET_DWORD(inbuf, MAC_STATS_IN_DMA_LEN, dma_len);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_MAC_STATS, inbuf, sizeof(inbuf),


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
