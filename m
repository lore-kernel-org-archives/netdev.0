From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 26 Jun 2007 15:42:47 +0200
Message-ID: <1182865367.3703.8.camel@johannes.berg>
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
	 <1182864796.5186.39.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sANYQJLcbmJurwrTZjA3"
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182864796.5186.39.camel@localhost>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sANYQJLcbmJurwrTZjA3
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-06-26 at 09:33 -0400, jamal wrote:
> On Tue, 2007-26-06 at 00:40 +0200, Johannes Berg wrote:
>=20
> > I wonder if we should hold off on this API until we've worked out the
> > multicast issue.
>=20
> I think we can fix all the code in one shot later.

Yes, we could fix the code in the kernel, but since the family ID is
dynamically assigned and I'm trying to decouple the multicast group ID
from the family ID that would break userspace relying on
family=3D=3Dmulticast group unless we somehow reserved the family ID number
ACPI got to make sure that ACPI gets the same multicast group ID.
Combined with the fact that ACPI might be modular and get into generic
netlink late in the game this seems non-trivial; also I think it's not
necessary since holding off on this ACPI genetlink multicast user (which
is the first besides the controller!) until we've worked out the patch
shouldn't hurt much.

>  I just glanced at
> your patch but i have to run out, i will stare at it later - seems to be
> in the right direction.

Thanks.

johannes

--=-sANYQJLcbmJurwrTZjA3
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGgRfX/ETPhpq3jKURAkpkAJwODCMaVnjO1IYhpT13ec5WVpYVdgCglV2M
/VrcJXTeKRcx+p1P/xs4rNo=
=5H+x
-----END PGP SIGNATURE-----

--=-sANYQJLcbmJurwrTZjA3--

