From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/9] [TCP]: Avoid clearing sacktag hint in trivial
 situations
Date: Thu, 20 Sep 2007 11:41:06 -0700 (PDT)
Message-ID: <20070920.114106.124084391.davem@davemloft.net>
References: <1190290672980-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723907-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11902906723220-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755221AbXITSlG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 14:41:06 -0400
In-Reply-To: <11902906723220-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 20 Sep 2007 15:17:52 +0300

> There's no reason to clear the sacktag skb hint when small part
> of the rexmit queue changes. Account changes (if any) instead when
> fragmenting/collapsing. RTO/FRTO do not touch SACKED_ACKED bits so
> no need to discard SACK tag hint at all.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, and I followed it up with this coding style fixlet.

Thanks!

commit e3723ad866a1e0690f3bc32443180ec1f6657f4a
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Thu Sep 20 11:40:37 2007 -0700

    [TCP]: Minor coding style fixup.
   =20
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 07b1faa..991ccdc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1067,14 +1067,16 @@ static inline void tcp_mib_init(void)
 }
=20
 /* from STCP */
-static inline void tcp_clear_retrans_hints_partial(struct tcp_sock *tp=
) {
+static inline void tcp_clear_retrans_hints_partial(struct tcp_sock *tp=
)
+{
 	tp->lost_skb_hint =3D NULL;
 	tp->scoreboard_skb_hint =3D NULL;
 	tp->retransmit_skb_hint =3D NULL;
 	tp->forward_skb_hint =3D NULL;
 }
=20
-static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp) {
+static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
+{
 	tcp_clear_retrans_hints_partial(tp);
 	tp->fastpath_skb_hint =3D NULL;
 }
