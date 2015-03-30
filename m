From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next] net: smc91x: Remove an unused variable
Date: Mon, 30 Mar 2015 13:43:38 -0300
Message-ID: <1427733818-11823-1-git-send-email-festevam@gmail.com>
Cc: u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:35872 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753333AbbC3Qnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 12:43:53 -0400
Received: by qcgx3 with SMTP id x3so19192027qcg.3
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 09:43:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Commit cb6e0b3690f48dff ("net: smc91x: make use of 4th parameter to devm_gpiod_get_index")
caused the following build warning:

drivers/net/ethernet/smsc/smc91x.c:2208:6: warning: unused variable 'res' [-Wunused-variable]

Remove the unused 'res' variable.

Reported-by: Olof's autobuilder <build@lixom.net>
Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/smsc/smc91x.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 5a1a3e7..14b363a 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -2205,7 +2205,6 @@ static int try_toggle_control_gpio(struct device *dev,
 {
 	struct gpio_desc *gpio = *desc;
 	enum gpiod_flags flags = value ? GPIOD_OUT_LOW : GPIOD_OUT_HIGH;
-	int res;
 
 	gpio = devm_gpiod_get_index_optional(dev, name, index, flags);
 	if (IS_ERR(gpio))
-- 
1.9.1
