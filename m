From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] [TCP]: Fix ratehalving with bidirectional
 flows
Date: Mon, 30 Jul 2007 19:49:46 -0700 (PDT)
Message-ID: <20070730.194946.08653937.davem@davemloft.net>
References: <Pine.LNX.4.64.0707301947210.8788@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0707302017290.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42862
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759081AbXGaCtz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 22:49:55 -0400
In-Reply-To: <Pine.LNX.4.64.0707302017290.8788@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 30 Jul 2007 20:18:45 +0300 (EEST)

> Actually, the ratehalving seems to work too well, as cwnd is
> reduced on every second ACK even though the packets in flight
> remains unchanged. Recoveries in a bidirectional flows suffer
> quite badly because of this, both NewReno and SACK are affected.
>=20
> After this patch, rate halving is performed for ACK only if
> packets in flight was supposedly changed too.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This fix looks great, and I see no potential problems with
Reno after doing a bit of auditing.

Applied and I'll push to -stable too.
