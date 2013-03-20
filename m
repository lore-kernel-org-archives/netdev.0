From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net: ethernet: davinci_emac: make local function
 emac_poll_controller() static
Date: Wed, 20 Mar 2013 23:01:45 +0800
Message-ID: <CAPgLHd8=u1jepO+Z0HExYyyybaYtVcdqk0yhtmnLUieUhEGLTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org
To: grant.likely@secretlab.ca, rob.herring@calxeda.com,
	davem@davemloft.net, mugunthanvnm@ti.com, jiri@resnulli.us,
	agust@denx.de, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:48752 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239Ab3CTPBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 11:01:51 -0400
Received: by mail-bk0-f52.google.com with SMTP id jk13so907272bkc.25
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 08:01:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

emac_poll_controller() was not declared. It should be static.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/ti/davinci_emac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index ae1b77a..e38e3d8 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -1438,7 +1438,7 @@ static int emac_poll(struct napi_struct *napi, int budget)
  * Polled functionality used by netconsole and others in non interrupt mode
  *
  */
-void emac_poll_controller(struct net_device *ndev)
+static void emac_poll_controller(struct net_device *ndev)
 {
 	struct emac_priv *priv = netdev_priv(ndev);
 
