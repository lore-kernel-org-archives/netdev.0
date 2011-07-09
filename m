From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 06/21] net: ibmveth: make rx_copybreak threshold consistent
 with other drivers
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <0cfacf59bf5003ca745953c6dfbf1d24779121d6.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Santiago Leon <santil@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51947 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753779Ab1GIRRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:54 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/ibmveth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 838c5b6..70c177d 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1074,7 +1074,7 @@ restart_poll:
 			skb =3D ibmveth_rxq_get_buffer(adapter);
=20
 			new_skb =3D NULL;
-			if (length < rx_copybreak)
+			if (length <=3D rx_copybreak)
 				new_skb =3D netdev_alloc_skb(netdev, length);
=20
 			if (new_skb) {
--=20
1.7.5.4

