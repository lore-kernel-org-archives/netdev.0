From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/3] au1000_eth: set MODULE_VERSION
Date: Tue, 28 Jul 2009 23:06:34 +0200
Message-ID: <200907282306.34622.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manuel Lauss <manuel.lauss@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:65134 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbZG1VGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:06:42 -0400
Received: by mail-ew0-f226.google.com with SMTP id 26so363258ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 14:06:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets MODULE_VERSION to ease the tracking
of the driver versions.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index f5611a5..04b9e85 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -81,6 +81,7 @@ static int au1000_debug = 3;
 
 MODULE_AUTHOR(DRV_AUTHOR);
 MODULE_DESCRIPTION(DRV_DESC);
+MODULE_VERSION(DRV_VERSION);
 MODULE_LICENSE("GPL");
 
 /*
