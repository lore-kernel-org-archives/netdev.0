From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/3] [TCP]: Comment fastpath_cnt_hint off-by-one trap
Date: Wed,  3 Oct 2007 14:00:17 +0300
Message-ID: <11914092181600-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <11914092183725-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45810 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754638AbXJCLAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 07:00:20 -0400
In-Reply-To: <11914092183725-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/tcp.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f8cf090..9ff456e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -343,7 +343,8 @@ struct tcp_sock {
 	struct sk_buff *forward_skb_hint;
 	struct sk_buff *fastpath_skb_hint;
=20
-	int     fastpath_cnt_hint;
+	int     fastpath_cnt_hint;	/* Lags behind by current skb's pcount
+					 * compared to respective fackets_out */
 	int     lost_cnt_hint;
 	int     retransmit_cnt_hint;
=20
--=20
1.5.0.6

