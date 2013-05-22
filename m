From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Subject: [PATCH 1/3] net: ethernet: apple: drop unused variable
Date: Wed, 22 May 2013 20:57:35 -0300
Message-ID: <1369267057-9371-1-git-send-email-emilio@elopez.com.ar>
References: <20130522.122624.266893118412034519.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
To: sfr@canb.auug.org.au, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zetta.elopez.com.ar ([199.30.59.35]:36655 "EHLO
	zetta.elopez.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab3EWAAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 20:00:21 -0400
In-Reply-To: <20130522.122624.266893118412034519.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 3b0aaef ("net: ethernet: apple: initialize variables directly")
dropped the only loop that was using i but did not remove the actual
variable, therefore causing a warning when building. This patch drops
the now redundant line.

Signed-off-by: Emilio L=C3=B3pez <emilio@elopez.com.ar>
---
 drivers/net/ethernet/apple/bmac.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/a=
pple/bmac.c
index 714dcfe..a597b76 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -1016,7 +1016,6 @@ static void bmac_set_multicast(struct net_device =
*dev)
 static void bmac_set_multicast(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
-	int i;
 	unsigned short rx_cfg;
 	u32 crc;
=20
--=20
1.8.2.3
