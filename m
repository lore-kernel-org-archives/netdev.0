From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH V2 net-next 1/2] liquidio: move macro definition to a proper
 place
Date: Mon, 21 Aug 2017 12:35:56 -0700
Message-ID: <20170821193556.GA6118@felix-thinkpad.cavium.com>
References: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0057.outbound.protection.outlook.com ([104.47.34.57]:59436
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753492AbdHUTfe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 15:35:34 -0400
Content-Disposition: inline
In-Reply-To: <20170821193527.GA6102@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

The macro LIO_CMD_WAIT_TM is not specific to the PF driver; it can be used
by the VF driver too, so move its definition from a PF-specific header file
to one that's common to PF and VF.

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h | 2 --
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h  | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index dee6046..2aba524 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -24,8 +24,6 @@
 
 #include "cn23xx_pf_regs.h"
 
-#define LIO_CMD_WAIT_TM 100
-
 /* Register address and configuration for a CN23XX devices.
  * If device specific changes need to be made then add a struct to include
  * device specific fields as shown in the commented section
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 906e30a..d0076c1 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -237,6 +237,8 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_VLAN_FILTER_ENABLE 0x1
 #define   OCTNET_CMD_VLAN_FILTER_DISABLE 0x0
 
+#define   LIO_CMD_WAIT_TM 100
+
 /* RX(packets coming from wire) Checksum verification flags */
 /* TCP/UDP csum */
 #define   CNNIC_L4SUM_VERIFIED             0x1
-- 
2.9.0
