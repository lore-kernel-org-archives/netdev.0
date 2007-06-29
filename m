From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 14:57:49 +0200
Message-ID: <1183121869.4089.57.camel@johannes.berg>
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
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-VCu6RSV7ZBu4+UFr7AKX"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35093 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbXF2M5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 08:57:35 -0400
In-Reply-To: <1182986681.5155.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-VCu6RSV7ZBu4+UFr7AKX
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-06-27 at 19:24 -0400, jamal wrote:

> a) i.e other than the reserved group for controller (which you seem to
> be taking care of), every other genetlink user has to explicitly
> register when they need a mcast group.=20

Hm. I'm starting to dislike the dynamic registration the more I think
about it. Now when a group is unregistered I'd have to unbind everybody
who's currently using it... At least when I want to enforce
root/non-root binds which is a further goal.

> c) Use a global hash table to store all the genl_multicast_groups;
> I think this (handwaving) should be searchable by i) name ii)ID and iii)
> family.=20

Also, it doesn't look like I'll ever be searching for a group unless we
want to allow userspace to explicitly ask for a group ID, but I'd think
it should just get the list of all IDs when asking for family
information and then cache that.

johannes

--=-VCu6RSV7ZBu4+UFr7AKX
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGhQHN/ETPhpq3jKURAr6/AJ9f3r8/cgjxhFmeJ1VFqbt57RoNjwCgohfK
48nto6hoibMREHvM1tsHSQg=
=6OZt
-----END PGP SIGNATURE-----

--=-VCu6RSV7ZBu4+UFr7AKX--

