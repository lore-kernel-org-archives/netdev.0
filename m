From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/2] usbnet: Print device statistics as unsigned
Date: Tue, 08 Jun 2010 19:20:59 +0100
Message-ID: <1276021259.2185.56.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:44631 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755775Ab0FHSVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:21:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/usb/usbnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index a95c73d..44115ee 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -643,7 +643,7 @@ int usbnet_stop (struct net_device *net)
 	netif_stop_queue (net);
 
 	netif_info(dev, ifdown, dev->net,
-		   "stop stats: rx/tx %ld/%ld, errs %ld/%ld\n",
+		   "stop stats: rx/tx %lu/%lu, errs %lu/%lu\n",
 		   net->stats.rx_packets, net->stats.tx_packets,
 		   net->stats.rx_errors, net->stats.tx_errors);
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

