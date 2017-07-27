From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: bump up driver version to match newer NIC
 firmware
Date: Thu, 27 Jul 2017 12:32:28 -0700
Message-ID: <20170727193228.GA1918@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0042.outbound.protection.outlook.com ([104.47.38.42]:8994
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751461AbdG0Tci (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 15:32:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bump up driver version to match newer NIC firmware.  Also update
nic_rx_stats (a struct common to host driver and firmware) by adding a new
field:  fw_total_fwd_bytes.

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 53aaf41..3b9e364 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -27,8 +27,8 @@
 
 #define LIQUIDIO_PACKAGE ""
 #define LIQUIDIO_BASE_MAJOR_VERSION 1
-#define LIQUIDIO_BASE_MINOR_VERSION 5
-#define LIQUIDIO_BASE_MICRO_VERSION 1
+#define LIQUIDIO_BASE_MINOR_VERSION 6
+#define LIQUIDIO_BASE_MICRO_VERSION 0
 #define LIQUIDIO_BASE_VERSION   __stringify(LIQUIDIO_BASE_MAJOR_VERSION) "." \
 				__stringify(LIQUIDIO_BASE_MINOR_VERSION)
 #define LIQUIDIO_MICRO_VERSION  "." __stringify(LIQUIDIO_BASE_MICRO_VERSION)
@@ -768,6 +768,7 @@ struct nic_rx_stats {
 	/* firmware stats */
 	u64 fw_total_rcvd;
 	u64 fw_total_fwd;
+	u64 fw_total_fwd_bytes;
 	u64 fw_err_pko;
 	u64 fw_err_link;
 	u64 fw_err_drop;
