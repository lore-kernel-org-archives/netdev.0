From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 1/2] net: sierra_net: make private symbols static
Date: Mon,  3 Sep 2012 11:20:32 +0200
Message-ID: <1346664033-30284-2-git-send-email-bjorn@mork.no>
References: <1346664033-30284-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47178 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367Ab2ICJUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 05:20:42 -0400
In-Reply-To: <1346664033-30284-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/sierra_net.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.=
c
index 7be49ea..596ddaa 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -560,7 +560,7 @@ static void sierra_net_defer_kevent(struct usbnet *=
dev, int work)
 /*
  * Sync Retransmit Timer Handler. On expiry, kick the work queue
  */
-void sierra_sync_timer(unsigned long syncdata)
+static void sierra_sync_timer(unsigned long syncdata)
 {
 	struct usbnet *dev =3D (struct usbnet *)syncdata;
=20
@@ -866,8 +866,8 @@ static int sierra_net_rx_fixup(struct usbnet *dev, =
struct sk_buff *skb)
 }
=20
 /* ---------------------------- Transmit data path -------------------=
---*/
-struct sk_buff *sierra_net_tx_fixup(struct usbnet *dev, struct sk_buff=
 *skb,
-		gfp_t flags)
+static struct sk_buff *sierra_net_tx_fixup(struct usbnet *dev,
+					   struct sk_buff *skb, gfp_t flags)
 {
 	struct sierra_net_data *priv =3D sierra_net_get_private(dev);
 	u16 len;
--=20
1.7.10.4
