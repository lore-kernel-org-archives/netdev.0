From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: [PATCH 1/2] drivers: net: phy: at803x: Add missing mdio device id
Date: Thu, 11 Jul 2013 13:57:34 +0200
Message-ID: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com>
Cc: davem@davemloft.net, Helmut Schaa <helmut.schaa@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:38212 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3GKL5p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 07:57:45 -0400
Received: by mail-ee0-f54.google.com with SMTP id t10so5491315eei.27
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 04:57:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

at803x supports Atheros 8030, 8031 and 8035 PHYs. 8031 was missing from
the mdio device id table.

Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
---
 drivers/net/phy/at803x.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
index 1f7091b..ac22283 100644
--- a/drivers/net/phy/at803x.c
+++ b/drivers/net/phy/at803x.c
@@ -217,6 +217,7 @@ module_exit(atheros_exit);
 
 static struct mdio_device_id __maybe_unused atheros_tbl[] = {
 	{ 0x004dd076, 0xffffffef },
+	{ 0x004dd074, 0xffffffef },
 	{ 0x004dd072, 0xffffffef },
 	{ }
 };
-- 
1.7.10.4
