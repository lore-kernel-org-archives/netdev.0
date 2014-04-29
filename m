From: Roland Dreier <roland@kernel.org>
Subject: [PATCH] cxgb4: Decode PCIe Gen3 link speed
Date: Mon, 28 Apr 2014 17:36:20 -0700
Message-ID: <1398731780-29236-1-git-send-email-roland@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog102.obsmtp.com ([74.125.245.72]:60342 "HELO
	na3sys010aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751400AbaD2Alb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 20:41:31 -0400
Received: by mail-pa0-f47.google.com with SMTP id fa1so438019pad.6
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2014 17:41:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>

Add handling for " 8 GT/s" in print_port_info().

Signed-off-by: Roland Dreier <roland@purestorage.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 6fe58913403a..24e16e3301e0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5870,6 +5870,8 @@ static void print_port_info(const struct net_device *dev)
 		spd = " 2.5 GT/s";
 	else if (adap->params.pci.speed == PCI_EXP_LNKSTA_CLS_5_0GB)
 		spd = " 5 GT/s";
+	else if (adap->params.pci.speed == PCI_EXP_LNKSTA_CLS_8_0GB)
+		spd = " 8 GT/s";
 
 	if (pi->link_cfg.supported & FW_PORT_CAP_SPEED_100M)
 		bufp += sprintf(bufp, "100/");
-- 
1.9.1
