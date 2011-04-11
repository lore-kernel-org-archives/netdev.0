From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding:set save_load to 0 when initializing
Date: Mon, 11 Apr 2011 11:56:47 -0700
Message-ID: <30474.1302548207@death>
References: <1302270019-11698-1-git-send-email-panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: =?UTF-8?q?Weiping=20Pan=28=E6=BD=98=E5=8D=AB=E5=B9=B3=29?=
	<panweiping3@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1302270019-11698-1-git-send-email-panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>It is unnecessary to set save_load to 1 here,
>as the tx_hashtbl is just kzalloced.
>
>Signed-off-by: Weiping Pan(=E6=BD=98=E5=8D=AB=E5=B9=B3) <panweiping3@g=
mail.com>

	I don't think this will cause any behavioral change, but I'll
grant is more correct in intent (there's no load information to save at
this point).

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

>---
> drivers/net/bonding/bond_alb.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond=
_alb.c
>index 9bc5de3..ab69e5a 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -176,7 +176,7 @@ static int tlb_initialize(struct bonding *bond)
> 	bond_info->tx_hashtbl =3D new_hashtbl;
>
> 	for (i =3D 0; i < TLB_HASH_TABLE_SIZE; i++) {
>-		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 1);
>+		tlb_init_table_entry(&bond_info->tx_hashtbl[i], 0);
> 	}
>
> 	_unlock_tx_hashtbl(bond);
>--=20
>1.7.4
>
