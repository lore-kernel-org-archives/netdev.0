From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [TCP]: Fix two off-by-one errors in fackets_out
 adjusting logic
Date: Sun, 07 Oct 2007 23:36:58 -0700 (PDT)
Message-ID: <20071007.233658.25210806.davem@davemloft.net>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11914092183725-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: legoater@free.fr, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37384
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751432AbXJHGg7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2007 02:36:59 -0400
In-Reply-To: <11914092183725-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed,  3 Oct 2007 14:00:16 +0300

> 1) Passing wrong skb to tcp_adjust_fackets_out could corrupt
> fastpath_cnt_hint as tcp_skb_pcount(next_skb) is not included
> to it if hint points exactly to the next_skb (it's lagging
> behind, see sacktag).
>=20
> 2) When fastpath_skb_hint is put backwards to avoid dangling
> skb reference, the skb's pcount must also be removed from count
> (not included like above).
>=20
> Reported by Cedric Le Goater <legoater@free.fr>
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied, thanks Ilpo.
