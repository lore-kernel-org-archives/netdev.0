From: David Miller <davem@davemloft.net>
Subject: Re: TCP_COOKIE_TRANSACTIONS synack data
Date: Mon, 08 Mar 2010 11:32:34 -0800 (PST)
Message-ID: <20100308.113234.109083822.davem@davemloft.net>
References: <1268064070.6148.104.camel@edumazet-laptop>
	<2BC93087D531FF4A98881820AFE8AE7B74C409E1D6@jklmail01.ixonos.local>
	<1268076495.2819.57.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mika.penttila@ixonos.com, netdev@vger.kernel.org,
	william.allen.simpson@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44569
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754115Ab0CHTcP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 14:32:15 -0500
In-Reply-To: <1268076495.2819.57.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Mar 2010 20:28:15 +0100

> [PATCH] tcp: Fix tcp_make_synack()
>=20
> Commit 4957faad (TCPCT part 1g: Responder Cookie =3D> Initiator), par=
t
> of TCP_COOKIE_TRANSACTION implementation, forgot to correctly size
> synack skb in case user data must be included.
>=20
> Many thanks to Mika Pentill=E4 for spotting this error.
>=20
> Reported-by: Penttill=E4 Mika <mika.penttila@ixonos.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks Eric, applied and I'll queue this up for 2.6.33-stable
