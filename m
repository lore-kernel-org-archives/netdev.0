From: Oliver Neukum <oneukum@suse.com>
Subject: [RFC/RFT PATCH 5/9] net: usb: mcs7830: use ksettings API
Date: Wed, 15 Mar 2017 16:02:44 +0100
Message-ID: <20170315150248.10997-6-oneukum@suse.com>
References: <20170315150248.10997-1-oneukum@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59862 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753913AbdCOPDl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 11:03:41 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 6B6F0AE06
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 15:03:38 +0000 (UTC)
In-Reply-To: <20170315150248.10997-1-oneukum@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes mcs7830 to use the new ksettings API of usbnet
and export the new methods to the network layer.

Signed-off-by: Oliver Neukum <oneukum@suse.com>
---
 drivers/net/usb/mcs7830.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 4f345bd..9e5f75c 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -464,9 +464,9 @@ static const struct ethtool_ops mcs7830_ethtool_ops = {
 	.get_link		= usbnet_get_link,
 	.get_msglevel		= usbnet_get_msglevel,
 	.set_msglevel		= usbnet_set_msglevel,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
 	.nway_reset		= usbnet_nway_reset,
+	.get_link_ksettings	= usbnet_get_ksettings,
+	.set_link_ksettings	= usbnet_set_ksettings
 };
 
 static const struct net_device_ops mcs7830_netdev_ops = {
-- 
2.10.2
