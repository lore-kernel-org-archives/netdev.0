From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 14:51:51 +0200
Message-ID: <1183121511.4089.53.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183023939.4769.76.camel@johannes.berg>  <4684F25B.5090607@trash.net>
	 <1183121180.4089.51.camel@johannes.berg>  <4684FF9A.10807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6LA5z19I0fohnDD5A6GU"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:58196 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764631AbXF2Mve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 08:51:34 -0400
In-Reply-To: <4684FF9A.10807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-6LA5z19I0fohnDD5A6GU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 14:48 +0200, Patrick McHardy wrote:

> > Hmm, another thought: since we have 32 bits for group numbers and 16
> > bits for families we could just reserve 16 bits for groups within each
> > family. Or do we get trouble with that because in some place there's a
> > group bitmap or such?
>=20
>=20
> Yes, af_netlink has a bitmap per socket that is subscribed to any group.

Not a good idea then. I'll see what I can do.

johannes

--=-6LA5z19I0fohnDD5A6GU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhQBm/ETPhpq3jKURAqrJAJ42Y2hrvCCaOTgs1AZYlm7iVb7KqQCaAz+V
DrqW+Uy52VYZaVT87utl2Tg=
=e/HP
-----END PGP SIGNATURE-----

--=-6LA5z19I0fohnDD5A6GU--

