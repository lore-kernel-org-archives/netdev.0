From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 28/28] usbnet: Support the get_ts_info ethtool method.
Date: Sun,  1 Apr 2012 17:20:13 +0200
Message-ID: <0499e330b43f1a6d775ebe6dc4d8c45b6c1220d3.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:44368 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab2DAPWU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 11:22:20 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1959432wgb.1
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 08:22:20 -0700 (PDT)
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333289292.git.richardcochran@gmail.com>
References: <cover.1333289292.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/usb/usbnet.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index b7b3f5b..db99536 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -884,6 +884,7 @@ static const struct ethtool_ops usbnet_ethtool_ops = {
 	.get_drvinfo		= usbnet_get_drvinfo,
 	.get_msglevel		= usbnet_get_msglevel,
 	.set_msglevel		= usbnet_set_msglevel,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 /*-------------------------------------------------------------------------*/
-- 
1.7.2.5
