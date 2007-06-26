From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 26 Jun 2007 10:50:13 +0200
Message-ID: <1182847813.3830.1.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182252616.21013.12.camel@johannes.berg>
	 <1182270006.4968.62.camel@localhost>
	 <1182338744.3714.59.camel@johannes.berg>
	 <1182440840.5017.40.camel@localhost>
	 <1182506947.21939.89.camel@johannes.berg>
	 <1182791337.5184.49.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-l+YzNrHgwtJ2msmnhAU0"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	lenb@kernel.org, Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:53907 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbXFZItp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 04:49:45 -0400
In-Reply-To: <1182791337.5184.49.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-l+YzNrHgwtJ2msmnhAU0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-25 at 13:08 -0400, jamal wrote:

> > Why do you think that would be hard? It'd basically just mean replacing
> > the netlink_capable(sock, NL_NONROOT_RECV) calls with a call that
> > actually tests depending on the group(s) it wants.
>=20
> I think it could be done. You will need to have root maybe initially set
> such permissions etc - but it may be overkill.

I think we pretty much know in the kernel whether we want to require
CAP_NET_ADMIN or not, let's punt the rest to userspace.

> > Yeah, sounds reasonable, you could ask the controller for which groups
> > are attached to a family and then get the IDs for those groups by name.
>=20
> Yes, we would need a newer api to do it right. But it could be done if
> you register for multi groups.

I've just replied somewhere else in this thread with a patch, I haven't
actually tested that patch yet though. Once the generic netlink
multicast is figured out we can start attacking the permissions issue.

johannes

--=-l+YzNrHgwtJ2msmnhAU0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGgNNF/ETPhpq3jKURAsbwAJ4tXLAj5wVJ+gqj01lqn8Rd5gCZdACfabgm
7r1bjMcyJBqWFzYiyANRco4=
=I6qT
-----END PGP SIGNATURE-----

--=-l+YzNrHgwtJ2msmnhAU0--

