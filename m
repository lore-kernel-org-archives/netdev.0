From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 10/11] net: cdc_ncm: fix argument alignment
Date: Sat, 10 May 2014 17:41:48 +0200
Message-ID: <1399736509-1159-11-git-send-email-bjorn@mork.no>
References: <1399736509-1159-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399736509-1159-1-git-send-email-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Reported-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
 drivers/net/usb/cdc_ncm.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 7d315b983e7e..c65145671521 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1316,14 +1316,14 @@ cdc_ncm_speed_change(struct usbnet *dev,
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

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
