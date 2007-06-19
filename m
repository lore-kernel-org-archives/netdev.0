From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 19 Jun 2007 13:30:16 +0200
Message-ID: <1182252616.21013.12.camel@johannes.berg>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-K45VSpWH6NveV9xO/pRW"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182178882.4063.11.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-K45VSpWH6NveV9xO/pRW
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2007-06-18 at 11:01 -0400, jamal wrote:

> Ok, by inspection (sorry, still dont have much time) - your kernel code
> is sending to group 1; i.e
>=20
> genlmsg_multicast(skb, 0, 1, GFP_ATOMIC);
>=20
> you need to change that to send to your assigned id, i.e:
> genlmsg_multicast(skb, 0, acpi_event_genl_family.id, GFP_ATOMIC);
>=20
> then the user space code will work. I should be able to look at it if it
> doesnt work by end of week.

Ah, that coincides with something I was wondering about. Isn't it
possible to have multiple multicast groups with generic netlink? If so,
we might have to use real netlink for wireless...

johannes

--=-K45VSpWH6NveV9xO/pRW
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGd75I/ETPhpq3jKURAiQPAJ4p4TZ+jNVtmFgSXpEmUtDNT9qHOgCghGOq
NTb3la9yFluVswAmxdEvHnQ=
=tC1F
-----END PGP SIGNATURE-----

--=-K45VSpWH6NveV9xO/pRW--

