From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 1/1] drivers: net: cpsw: Add support for new CPSW IP version present in AM43xx SoC
Date: Mon, 12 Aug 2013 17:11:15 +0530
Message-ID: <1376307675-11501-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-omap@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56903 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756020Ab3HLLlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Aug 2013 07:41:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new IP version which is present in AM43xx SoC has a minor changes and the
offsets are same as the previous version, so adding new IP version support in
the driver.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index cd95671..0fcf212 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -83,6 +83,7 @@ do {								\
 #define CPSW_VERSION_1		0x19010a
 #define CPSW_VERSION_2		0x19010c
 #define CPSW_VERSION_3		0x19010f
+#define CPSW_VERSION_4		0x190112
 
 #define HOST_PORT_NUM		0
 #define SLIVER_SIZE		0x40
@@ -993,6 +994,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 		break;
 	case CPSW_VERSION_2:
 	case CPSW_VERSION_3:
+	case CPSW_VERSION_4:
 		slave_write(slave, TX_PRIORITY_MAPPING, CPSW2_TX_PRI_MAP);
 		break;
 	}
@@ -2018,6 +2020,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		break;
 	case CPSW_VERSION_2:
 	case CPSW_VERSION_3:
+	case CPSW_VERSION_4:
 		priv->host_port_regs = ss_regs + CPSW2_HOST_PORT_OFFSET;
 		priv->cpts->reg      = ss_regs + CPSW2_CPTS_OFFSET;
 		priv->hw_stats	     = ss_regs + CPSW2_HW_STATS;
-- 
1.8.4.rc1.21.gfb56570
