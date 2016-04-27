From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?Q?don=E2=80=99t?= modify
 ip_summed; doing so treats packets with bad checksums as good.
Date: Wed, 27 Apr 2016 20:07:49 +0200
Message-ID: <1461780469.5102.0.camel@decadent.org.uk>
References: <lsq.1461711744.699003961@decadent.org.uk>
	 <5720E1F0.9010203@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-yJJVXtP3DtRwt84qu0z5"
Cc: akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Ben Greear <greearb@candelatech.com>, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5720E1F0.9010203@candelatech.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-yJJVXtP3DtRwt84qu0z5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-04-27 at 08:59 -0700, Ben Greear wrote:
> On 04/26/2016 04:02 PM, Ben Hutchings wrote:
> >=20
> > 3.2.80-rc1 review patch.=C2=A0=C2=A0If anyone has any objections, pleas=
e let me know.
> I would be careful about this.=C2=A0=C2=A0It causes regressions when send=
ing
> PACKET_SOCKET buffers from user-space to veth devices.
>=20
> There was a proposed upstream fix for the regression, but it has not gone
> into the tree as far as I know.
>=20
> http://www.spinics.net/lists/netdev/msg370436.html
[...]

OK, I'll drop this for now.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.
--=-yJJVXtP3DtRwt84qu0z5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXIP/1AAoJEOe/yOyVhhEJUDsQAJ15FuYzbF9Po4XuBxMDT2QJ
BebRpA0KpCrtiV+ByAUYUYD0FnFz0pWAnG5RzpD2MasmUns8kN1Pk/F8tinzAeUz
P/t75bTh62Gh12UfmBc6AJgy+7e3Q4i6ymOf1cS7yBrg/Wq8QwUlOifdZdehIqQy
cLBqbIoIR8N7Vp1e4cB3DcoGb4RYQc49QP50SqfBIU++ugS9dxX5aQw165nigb1G
Z+5cGsUGYDuXT9lSsCMlg758IAxd4TJYx1/2n9VfD9xF/bRuORHWvPref3sX3hqX
JSYpnOAptIpF5mw5H50NAaDIuZQ/LA8blL6mN1jlLaoiwXE8eyZoN1BSvkAUkmyk
vjGIw0/gSMEZv/sjCZJZ6mU7+37pk4LvNQNRdpiod3Jy3iGv+otKogCOomK4G8GN
po7Xx5hDj1crkAxbf5YTxHc/0YO2RsFY4OEetntXLTL1/ZemIrDaawQdOF13IkOf
pKwKzbwyBeEj/vgkzcFjjT3P0y4VpCAI0uEeoEMa9VrECttiRNY/z7jDRCmhscJx
0UCJfyl7pvm6P/IBxfcxXbrGzVlRyVp5Fr+b8GOXRRHibEkAttVccBfOP45LfE8a
rEnE75U5H9HglG9A3rZplDRX0DmDQuqlKxBydia9Ncl1O+5HOOYLwRyCJbu2GkdJ
QgGKvhqb/tp3AdcM7DA2
=L7lx
-----END PGP SIGNATURE-----

--=-yJJVXtP3DtRwt84qu0z5--
