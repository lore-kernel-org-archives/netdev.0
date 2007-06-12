From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 11:19:57 +0200
Message-ID: <1181639998.29767.59.camel@johannes.berg>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-u2KMVWGaoFH5YxePNudJ"
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49028 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbXFLJTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 05:19:48 -0400
In-Reply-To: <1181564611.4043.220.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-u2KMVWGaoFH5YxePNudJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-11 at 08:23 -0400, jamal wrote:
> On Mon, 2007-11-06 at 13:58 +0200, Patrick McHardy wrote:
>=20
> > Thats not true. Assume PSL has lots of packets, PSH is empty. We
> > fill the PHL queue until their is no room left, so the driver
> > has to stop the queue.=20
>=20
> Sure. Packets stashed on the any DMA ring are considered "gone to the
> wire". That is a very valid assumption to make.

Not at all! Packets could be on the DMA queue forever if you're feeding
out more packets. Heck, on most wireless hardware packets can even be
*expired* from the DMA queue and you get an indication that it was
impossible to send them.

johannes

--=-u2KMVWGaoFH5YxePNudJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGbmU9/ETPhpq3jKURAkYIAJ9o0euf6Fm9zFdWUiZwYXae+OCtLACffkzk
oP9QUkfNtjJeX75JMHQ6AtY=
=0UcE
-----END PGP SIGNATURE-----

--=-u2KMVWGaoFH5YxePNudJ--

