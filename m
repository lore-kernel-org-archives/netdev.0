From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 4/9] net: usb: dm9601: use ksettings API
Date: Wed, 15 Mar 2017 16:02:43 +0100
Message-ID: <20170315150248.10997-5-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59854 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753906AbdCOPDk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:40 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 51596AE05
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes dm9601 to use the new ksettings API of usbnet
and export the new methods to the network layer.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/dm9601.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 0b4bdd3..b604cd4 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -281,9 +281,9 @@ static const struct ethtool_ops dm9601_ethtool_ops = {
 	.set_msglevel	= usbnet_set_msglevel,
 	.get_eeprom_len	= dm9601_get_eeprom_len,
 	.get_eeprom	= dm9601_get_eeprom,
-	.get_settings	= usbnet_get_settings,
-	.set_settings	= usbnet_set_settings,
 	.nway_reset	= usbnet_nway_reset,
+	.set_link_ksettings	= usbnet_set_ksettings,
+	.get_link_ksettings	= usbnet_get_ksettings
 };
 
 static void dm9601_set_multicast(struct net_device *net)
-- 
2.10.2
