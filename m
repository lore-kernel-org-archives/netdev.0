From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [TCP]: Fix reord detection due to snd_una covered
 holes
Date: Sat, 10 Nov 2007 21:22:40 -0800 (PST)
Message-ID: <20071110.212240.31482289.davem@davemloft.net>
References: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40707
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751304AbXKKFWm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2007 00:22:42 -0500
In-Reply-To: <11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 10 Nov 2007 12:56:00 +0200

> Fixes subtle bug like the one with fastpath_cnt_hint happening
> due to the way the GSO and hints interact. Because hints are not
> reset when just a GSOed skb is partially ACKed, there's no
> guarantee that the relevant part of the write queue is going to
> be processed in sacktag at all (skbs below snd_una) because
> fastpath hint can fast forward the entrypoint.
>=20
> This was also on the way of future reductions in sacktag's skb
> processing. Also future cleanups in sacktag can be made after
> this (in 2.6.25).
>=20
> This may make reordering update in tcp_try_undo_partial
> redundant but I'm not too sure so I left it there.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Thanks for discovering this.

Applied, thanks.
