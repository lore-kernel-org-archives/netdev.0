From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] tcp: remove pointless .dsack/.num_sacks code
Date: Sun, 15 Mar 2009 20:10:20 -0700 (PDT)
Message-ID: <20090315.201020.152587350.davem@davemloft.net>
References: <1237075675426-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35123
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751539AbZCPDKe convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2009 23:10:34 -0400
In-Reply-To: <1237075675426-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sun, 15 Mar 2009 02:07:49 +0200

> In the pure assignment case, the earlier zeroing is
> still in effect.
>=20
> David S. Miller raised concerns if the ifs are there to avoid
> dirtying cachelines. I came to these conclusions:
>=20
> > We'll be dirty it anyway (now that I check), the first "real" state=
ment
> > in tcp_rcv_established is:
> >
> >       tp->rx_opt.saw_tstamp =3D 0;
> >
> > ...that'll land on the same dword. :-/
> >
> > I suppose the blocks are there just because they had more complexit=
y
> > inside when they had to calculate the eff_sacks too (maybe it would
> > have been better to just remove them in that drop-patch so you woul=
d
> > have had less head-ache :-)).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
