From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV4] ip_gre: set mac_header correctly in receive path
Date: Thu, 20 Dec 2007 00:11:27 -0800 (PST)
Message-ID: <20071220.001127.23448802.davem@davemloft.net>
References: <20071024100842.GA19369@ms2.inr.ac.ru>
	<4767D249.5050602@iki.fi>
	<47695EA1.10103@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750911AbXLTILe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 03:11:34 -0500
In-Reply-To: <47695EA1.10103@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo_Ter=E4s <timo.teras@iki.fi>
Date: Wed, 19 Dec 2007 20:10:41 +0200

> From: Timo Teras <timo.teras@iki.fi>
>=20
> mac_header update in ipgre_recv() was incorrectly changed to
> skb_reset_mac_header() when it was introduced.
>=20
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Patch applied, thanks.

> ---
> This replaces my earlier patch titled "ip_gre: use skb->{mac,
> network}_header consistently". Apparently I hadn't done my homework h=
ow
> to use *_header correctly. And I should have done a bit more testing =
to
> figure out the previous patch does not work.
>=20
> But the main problem was the receive path in the first place, and thi=
s
> patch fixes it.
>=20
> The bug was introduced in commit 459a98ed881802dee55897441bc7f77af614=
368e.
> There might be other similar incorrect replaces.

That commit has two other identical bad conversions, I'll
fix them up.
