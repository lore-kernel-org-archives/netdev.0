From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 3/3] ne2: silence static never defined warnings
Date: Fri, 28 Nov 2008 19:53:38 +0200
Message-ID: <1227894818582-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12278948183224-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12278948182487-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47350 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbYK1Rxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 12:53:41 -0500
In-Reply-To: <12278948182487-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These warning originate from 50014f1 (ne2: convert to
net_device_ops) which did drop those functions.

drivers/net/ne2.c:140: warning: 'ne_open' declared 'static' but never d=
efined
drivers/net/ne2.c:141: warning: 'ne_close' declared 'static' but never =
defined

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/ne2.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
index 8d61807..a53bb20 100644
--- a/drivers/net/ne2.c
+++ b/drivers/net/ne2.c
@@ -137,9 +137,6 @@ extern int netcard_probe(struct net_device *dev);
=20
 static int ne2_probe1(struct net_device *dev, int slot);
=20
-static int ne_open(struct net_device *dev);
-static int ne_close(struct net_device *dev);
-
 static void ne_reset_8390(struct net_device *dev);
 static void ne_get_8390_hdr(struct net_device *dev, struct e8390_pkt_h=
dr *hdr,
 		int ring_page);
--=20
1.5.2.2

