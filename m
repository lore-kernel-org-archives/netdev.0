From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH tcp-2.6 1/2] [TCP]: Discard fuzzy SACK blocks
Date: Mon, 18 Jun 2007 23:16:46 -0700 (PDT)
Message-ID: <20070618.231646.71856685.davem@davemloft.net>
References: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1182205558564-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53656
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754056AbXFSGQ2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 02:16:28 -0400
In-Reply-To: <1182205558564-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Tue, 19 Jun 2007 01:25:57 +0300

> From: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>
>=20
> SACK processing code has been sort of russian roulette as no
> validation of SACK blocks is previously attempted. It is not
> very clear what all kinds of broken SACK blocks really mean
> (e.g., one that has start and end sequence numbers reversed).
>=20
> This fixes also one remote triggerable NULL-ptr access:
> start_seq was trusted as a valid mark_lost_entry_seq but
> without validation it is relatively easy to inject an invalid
> sequence number there that will cause a crash in the lost
> marker code. Other SACK processing code seems safe so this could
> have been fixed locally but that would leave SACK processing
> hazardous in case of future modifications. IMHO, it's just
> better to close the whole roulette rather than disarming just
> one bullet.
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

This looks good applied.

Does mainline 2.6.x has this NULL-ptr issues too?  If so
we'll have to fix it there very soon.
