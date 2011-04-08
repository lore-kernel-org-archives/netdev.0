From: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Subject: [PATCH] bonding:set save_load to 0 when initializing
Date: Fri,  8 Apr 2011 21:40:19 +0800
Message-ID: <1302270019-11698-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?q?Weiping=20Pan (=E6=BD=98=E5=8D=AB=E5=B9=B3) ?=
	<panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is unnecessary to set save_load to 1 here,
as the tx_hashtbl is just kzalloced.

Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@gm=
ail.com>
---
 drivers/net/bonding/bond_alb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
index 9bc5de3..ab69e5a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -176,7 +176,7 @@ static int tlb_initialize(struct bonding *bond)
 	bond_info->tx_hashtbl =3D new_hashtbl;
=20
 	for (i =3D 0; i < TLB_HASH_TABLE_SIZE; i++) {
-		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 1);
+		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 0);
 	}
=20
 	_unlock_tx_hashtbl(bond);
--=20
1.7.4
