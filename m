From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] hso: add missing last_rx setting
Date: Thu, 04 Jun 2009 18:50:23 +0300
Message-ID: <20090604155019.6660.33231.stgit@Programuotojas>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: j.dumon@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:53336 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753057AbZFDPuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2009 11:50:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
---

 drivers/net/usb/hso.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index f84b78d..1064dda 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -958,8 +958,8 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 
 				/* update out statistics */
 				odev->net->stats.rx_packets++;
-
 				odev->net->stats.rx_bytes += odev->rx_buf_size;
+				odev->net->last_rx = jiffies;
 
 				odev->rx_buf_size = 0;
 				odev->rx_buf_missing = sizeof(struct iphdr);

