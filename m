From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Subject: [PATCH 2/3] net: ethernet: korina: drop unused variable
Date: Wed, 22 May 2013 20:57:36 -0300
Message-ID: <1369267057-9371-2-git-send-email-emilio@elopez.com.ar>
References: <20130522.122624.266893118412034519.davem@davemloft.net>
 <1369267057-9371-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
To: sfr@canb.auug.org.au, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369267057-9371-1-git-send-email-emilio@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit e998fd4 ("net: ethernet: korina: initialize variables directly")
dropped the only loop that was using i but did not remove the actual
variable, therefore causing a warning when building. This patch drops
the now redundant line.

Signed-off-by: Emilio L=C3=B3pez <emilio@elopez.com.ar>
---
 drivers/net/ethernet/korina.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korin=
a.c
index 0b57085..e7851d1 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -483,7 +483,6 @@ static void korina_multicast_list(struct net_device=
 *dev)
 	unsigned long flags;
 	struct netdev_hw_addr *ha;
 	u32 recognise =3D ETH_ARC_AB;	/* always accept broadcasts */
-	int i;
=20
 	/* Set promiscuous mode */
 	if (dev->flags & IFF_PROMISC)
--=20
1.8.2.3
