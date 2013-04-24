From: Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH] mac80211_hwsim: correctly register the platform driver
Date: Wed, 24 Apr 2013 12:53:21 +0200
Message-ID: <20130424105321.GA2898@piware.de>
References: <1366778405-7584-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: johannes@sipsolutions.net, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dcbw@redhat.com
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1366778405-7584-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Sasha,

Sasha Levin [2013-04-24  0:40 -0400]:
> Not registering a platform_driver would make us access garbage
> when the platform callbacks under driver_register() kicks in.
>=20
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Ah, thanks for catching this! I applied that patch and verified that
it still works well.

Tested-By: Martin Pitt <martin.pitt@ubuntu.com>

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRd7mhAAoJEPmIJawmtHufgSsP/jKmdrVPj69ClRn4sgySd0TH
UmEvACPZQ+8Z9KCWnERDDL7f/RsHELFJ7LebyTsauaOhkTJqWJGRybX7PT7QDlul
NHoCPXUcIKX2QNxgn2biWa2rcGx5YYXf/xeibdsqPi0BLsOVXn1nAykYlJbcbyJl
M7uThqtLl8V4PVqliEhtSa2ch6idkMIavIqFME5HmmQ6d0/AL3OlL5ZM9vftg/g0
2pk7kEJHonbUBtQCv0v4vhkypUidJzEZi5vaWqpfa0MmtKfeQIYx+LSBDQhHsOH5
RSDh4KtJTgR78aGgC8myTqsYj5WLdxRXTcwDWfk61tdd05ND/g8oeEHVdqXGubxc
CvalZCAsRBbYX0WIxUljE46fuxyzazBEBZIiGd13gTF22O9jUdEyDWtYfo7aPUyp
7EU+YvpgynNl4kSY3XnIK0aOZeZa4zMYISPyMF6Bx4Bs/Oi5kpXlGJDoz6R9+5AJ
a+9veRiWlpJDnGv6i+VntEih8B/yvaIjx9rzhq+4kbB+bOOC9DiSlrQuz7BUYNJ8
taSeOI0A3dX4Xp5uL1uy02d9eWkrkHVCsJWLfQKjCNJIgkEzqa4mrXa79kGkSJm7
y58jGExddG/60J9Mdt1SJZ2I3GmL4kjzmRbijFkoNuP6OK8Qs7LQVMrtjnATTMfU
WM8Uu08CGGvWzqz+JtZR
=y4W9
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
