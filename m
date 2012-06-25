From: sjur.brandeland@stericsson.com
Subject: [net-next 07/11] caif-hsi: Remove uncecessary assignments
Date: Mon, 25 Jun 2012 19:49:39 +0200
Message-ID: <1340646583-21059-8-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?=
	<sjur.brandeland@stericssion.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54537 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600Ab2FYRuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:04 -0400
Received: by bkcji2 with SMTP id ji2so3429825bkc.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:50:03 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Remove assignment at declaration when not needed.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericssion.com>
---
 drivers/net/caif/caif_hsi.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index f7997a7..d80759e 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -246,8 +246,8 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 	/* Check if we can embed a CAIF frame. */
 	if (skb->len < CFHSI_MAX_EMB_FRM_SZ) {
 		struct caif_payload_info *info;
-		int hpad =3D 0;
-		int tpad =3D 0;
+		int hpad;
+		int tpad;
=20
 		/* Calculate needed head alignment and tail alignment. */
 		info =3D (struct caif_payload_info *)&skb->cb;
@@ -282,8 +282,8 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 	pfrm =3D desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
 	while (nfrms < CFHSI_MAX_PKTS) {
 		struct caif_payload_info *info;
-		int hpad =3D 0;
-		int tpad =3D 0;
+		int hpad;
+		int tpad;
=20
 		if (!skb)
 			skb =3D cfhsi_dequeue(cfhsi);
@@ -573,7 +573,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 		struct sk_buff *skb;
 		u8 *dst =3D NULL;
 		u8 *pcffrm =3D NULL;
-		int len =3D 0;
+		int len;
=20
 		/* CAIF frame starts after head padding. */
 		pcffrm =3D pfrm + *pfrm + 1;
--=20
1.7.5.4
