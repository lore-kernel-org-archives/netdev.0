From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26] [AF_KEY]: Dump SA/SP entries non-atomically
Date: Mon, 03 Mar 2008 23:40:44 -0800 (PST)
Message-ID: <20080303.234044.216355223.davem@davemloft.net>
References: <47CBB178.2020809@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44098
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752151AbYCDHkp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 02:40:45 -0500
In-Reply-To: <47CBB178.2020809@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Mon, 03 Mar 2008 10:06:16 +0200

> Stop dumping of entries when af_key socket receive queue is getting f=
ull
> and continue it later when there is more room again.
>=20
> This fixes dumping of large databases. Currently the entries not fitt=
ing
> into the receive queue are just dropped (including the end-of-dump
> message) which can confuse applications.
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Applied to net-2.6.26, thanks a lot for doing this work.
