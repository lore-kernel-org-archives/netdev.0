From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 03/17] tcp: fix lost_cnt_hint miscounts
Date: Mon, 02 Mar 2009 03:01:09 -0800 (PST)
Message-ID: <20090302.030109.01266821.davem@davemloft.net>
References: <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46953
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755681AbZCBLB1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 06:01:27 -0500
In-Reply-To: <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 28 Feb 2009 16:44:28 +0200

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> It is possible that lost_cnt_hint gets underflow in
> tcp_clean_rtx_queue because the cumulative ACK can cover
> the segment where lost_skb_hint points to only partially,
> which means that the hint is not cleared, opposite to what
> my (earlier) comment claimed.
>=20
> Also I don't agree what I ended up writing about non-trivial
> case there to be what I intented to say. It was not supposed
> to happen that the hint won't get cleared and we underflow
> in any scenario.
>=20
> In general, this is quite hard to trigger in practice.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
