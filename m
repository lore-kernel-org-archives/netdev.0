From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:49:41 +0200
Message-ID: <1183124981.4089.69.camel@johannes.berg>
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
	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>
	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>
	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pTHPmrF45wLz+mgLQcCS"
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51250 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763499AbXF2Nt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 09:49:27 -0400
In-Reply-To: <46850CB8.8000509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-pTHPmrF45wLz+mgLQcCS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-06-29 at 15:44 +0200, Patrick McHardy wrote:

> > How about for now I only allow dynamic registration (no unregistration)
> > and just send out when new groups are registered, and also give
> > userspace a list of registered mc groups when they ask for a family
> > description? That should make this patch not too big and still leaves
> > room for dynamic unregistration later.
>=20
>=20
> How does it deal with unregistration currently? If it leaves sockets
> subscribed that seems like a bug already, at least if the id was
> dynamically generated. Of course it would require the id to be
> reused to actually matter.

Hmm. I don't see it kicking out the socket subscriptions in
genl_unregister_family so I guess that bug is present.

johannes

--=-pTHPmrF45wLz+mgLQcCS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhQ31/ETPhpq3jKURAnSlAKC7FxmOei3GdY7h+HWPoOzTtCDtEgCbBFlf
TF9SfN7tgvtoydEZW0NWfCM=
=X1oE
-----END PGP SIGNATURE-----

--=-pTHPmrF45wLz+mgLQcCS--

