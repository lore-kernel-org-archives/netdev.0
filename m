From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Subject: [PATCH v2 4/4] net: ethernet: korina: initialize variables directly
Date: Fri, 17 May 2013 17:42:56 -0300
Message-ID: <1368823376-13104-4-git-send-email-emilio@elopez.com.ar>
References: <1368803268-27698-1-git-send-email-emilio@elopez.com.ar>
 <1368823376-13104-1-git-send-email-emilio@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368823376-13104-1-git-send-email-emilio@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clean up the code a bit to initialize the variables directly when
defining them.

Signed-off-by: Emilio L=C3=B3pez <emilio@elopez.com.ar>
---

Please note that this patch is untested.

Changes from v1:
  - {0} -> { 0 } as suggested by David Miller

 drivers/net/ethernet/korina.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korin=
a.c
index 5409fe8..3756d95 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -495,12 +495,9 @@ static void korina_multicast_list(struct net_devic=
e *dev)
=20
 	/* Build the hash table */
 	if (netdev_mc_count(dev) > 4) {
-		u16 hash_table[4];
+		u16 hash_table[4] =3D { 0 };
 		u32 crc;
=20
-		for (i =3D 0; i < 4; i++)
-			hash_table[i] =3D 0;
-
 		netdev_for_each_mc_addr(ha, dev) {
 			crc =3D ether_crc_le(6, ha->addr);
 			crc >>=3D 26;
--=20
1.8.2.3
