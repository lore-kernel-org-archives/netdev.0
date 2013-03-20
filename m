From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net: fec: make local function fec_poll_controller() static
Date: Wed, 20 Mar 2013 23:06:11 +0800
Message-ID: <CAPgLHd-ZLKjHdqc_Bm44co+9eTF48TOg9zY8c1jbqeG+jnn3GQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	davem@davemloft.net, Frank.Li@freescale.com, shawn.guo@linaro.org,
	fabio.estevam@freescale.com, s.hauer@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:65138 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3CTPGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 11:06:13 -0400
Received: by mail-bk0-f54.google.com with SMTP id w5so928426bku.41
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 08:06:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

fec_poll_controller() was not declared. It should be static.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/freescale/fec.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index e3f3937..1ece68b 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1559,7 +1559,7 @@ fec_set_mac_address(struct net_device *ndev, void *p)
  * Polled functionality used by netconsole and others in non interrupt mode
  *
  */
-void fec_poll_controller(struct net_device *dev)
+static void fec_poll_controller(struct net_device *dev)
 {
 	int i;
 	struct fec_enet_private *fep = netdev_priv(dev);
