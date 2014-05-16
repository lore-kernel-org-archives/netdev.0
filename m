From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v2 10/12] net: cdc_ncm: fix argument alignment
Date: Fri, 16 May 2014 21:48:27 +0200
Message-ID: <1400269709-18854-11-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52177 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757423AbaEPTsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:48:51 -0400
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index bb53abe1f3a1..1d1ff2fa8ae1 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1327,14 +1327,14 @@ cdc_ncm_speed_change(struct usbnet *dev,
 	 */
 	if ((tx_speed > 1000000) && (rx_speed > 1000000)) {
 		netif_info(dev, link, dev->net,
-		       "%u mbit/s downlink %u mbit/s uplink\n",
-		       (unsigned int)(rx_speed / 1000000U),
-		       (unsigned int)(tx_speed / 1000000U));
+			   "%u mbit/s downlink %u mbit/s uplink\n",
+			   (unsigned int)(rx_speed / 1000000U),
+			   (unsigned int)(tx_speed / 1000000U));
 	} else {
 		netif_info(dev, link, dev->net,
-		       "%u kbit/s downlink %u kbit/s uplink\n",
-		       (unsigned int)(rx_speed / 1000U),
-		       (unsigned int)(tx_speed / 1000U));
+			   "%u kbit/s downlink %u kbit/s uplink\n",
+			   (unsigned int)(rx_speed / 1000U),
+			   (unsigned int)(tx_speed / 1000U));
 	}
 }
=20
--=20
2.0.0.rc2
