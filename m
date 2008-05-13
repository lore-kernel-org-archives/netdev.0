From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] hamradio/scc: add missing block braces to multi-statement if
Date: Tue, 13 May 2008 14:16:53 +0300
Message-ID: <1210677414-16380-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58824 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbYEMLQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 07:16:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 drivers/net/hamradio/scc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index f905159..45ae9d1 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -1340,9 +1340,10 @@ static unsigned int scc_set_param(struct scc_cha=
nnel *scc, unsigned int cmd, uns
 		case PARAM_RTS:=09
 			if ( !(scc->wreg[R5] & RTS) )
 			{
-				if (arg !=3D TX_OFF)
+				if (arg !=3D TX_OFF) {
 					scc_key_trx(scc, TX_ON);
 					scc_start_tx_timer(scc, t_txdelay, scc->kiss.txdelay);
+				}
 			} else {
 				if (arg =3D=3D TX_OFF)
 				{
--=20
1.5.2.2

