From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] i40e: Reduce stack in i40e_dbg_dump_desc
Date: Mon, 17 Nov 2014 13:30:45 -0800
Message-ID: <1416259845.2431.2.camel@jtkirshe-mobl.jf.intel.com>
References: <1416031715-32498-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5467C3BA.6090003@gmail.com> <1416175968.24600.1.camel@perches.com>
	 <20141117.160636.429874041980998120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-5bYwus2NCWTAKYqzAVTL"
Cc: joe@perches.com, shannon.nelson@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:13060 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbaKQVaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 16:30:46 -0500
In-Reply-To: <20141117.160636.429874041980998120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5bYwus2NCWTAKYqzAVTL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-11-17 at 16:06 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sun, 16 Nov 2014 14:12:48 -0800
>=20
> > Reduce stack use by using kmemdup and not using a very
> > large struct on stack.
> >=20
> > In function =E2=80=98i40e_dbg_dump_desc=E2=80=99:
> > warning: the frame size of 8192 bytes is larger than 2048 bytes [-Wfram=
e-larger-than=3D]
> >=20
> > Signed-off-by: Joe Perches <joe@perches.com>
>=20
> I'll let Jeff pick this one up, thanks.

Consider it picked up.  Sorry, trying to catch up on all the
email/patches the went out this weekend.

--=-5bYwus2NCWTAKYqzAVTL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUamkFAAoJEOVv75VaS+3O3x8P/0iU8ysvplmHo7XrNB6Izp6v
l9+mwxuOwafupTyxKtYa2ZQEImV0BLPXM4GMpttTzMIkGmWu288zVqk/N3UAHqr0
1rqOcFxZgOJ/G5RqKg5e05E/cLHe6qbEUHwm2T1wP0xrUEXciFH3ZdsWTkZH3kGh
iE0/0xDjZyzSiINfsWnBRuGjlUEjF6rz8Dhx/McGAA9uUOWAIh1awWuXsoTJIg/K
qqRleNICWRboMFuD/jv/0QQp4sL/9Mj5qjL4jaQUo+YMt2IpRhHWh8x0MoXxxM9/
bnsnt7027FBXJ1wHDJeaAvJ376RVkOdxQUszOzgn8dKndafdGS6jHI+0ZPGUZSpr
pbhSI7EeHcDH/wRYIuWhXYtfTlh+pgFtSSLAy0A+8/xW61293b8Nxd56ZBdUUKa6
cl7XivTpE1UC9anpRnTkuuigVsBRVlYhj1MtHoL56PlIBs92J79rqCt/Jn3LtCA8
eTu5neq8Rzzi5dZ7PHujjTWeC1E/rWqmQxgBAsgLL7ujNnE/gxEhexMhMHSFGGes
po1ykH95PZRLOk4BCGx86v4zDhB/WWoUvJazi6yeVuGQgbueHeGS+759cDX3xZkw
S58ZaRDHID/StZlKcaH0zIPZist6n8kB/CehW/7gpm3CoQNqUx4okKW7RWOkubSL
XGddqK4Euc+QPBwuROC0
=hId0
-----END PGP SIGNATURE-----

--=-5bYwus2NCWTAKYqzAVTL--
