From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: drivers/net: Kconfig & Makefile cleanup
Date: Wed, 23 Nov 2011 12:58:09 -0800
Message-ID: <1322081889.2282.8.camel@jtkirshe-mobl>
References: <1321944512.2839.219.camel@deadeye>
	 <1321944662.2839.222.camel@deadeye>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KEqYOnV3MrudJGu99thh"
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63925 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752819Ab1KWU6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 15:58:10 -0500
In-Reply-To: <1321944662.2839.222.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KEqYOnV3MrudJGu99thh
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-11-21 at 22:51 -0800, Ben Hutchings wrote:
> ou wrote that (some time ago now):
> > As a side cleanup, found that the arcnet, token ring, and PHY
> > Kconfig options were a tri-state option and should have been
> > a bool option.
>=20
> How did you decide that?  This seems to be correct for TR, but ARCNET
> and PHYLIB each select some support code that can be built as a module
> (and which has been, in Debian).
>=20
> Ben.=20

Off the top of my head, I was making the decision based on the other
protocols Kconfig entries.

So does that mean ARCNET could be a module and a driver using ARCNET
would have to be a module as well?

I will take a look at this to come up with a solution, if one has not
been sent out yet.

--=-KEqYOnV3MrudJGu99thh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOzV5hAAoJEOVv75VaS+3OdQsP/0zAY+ZpUD74Cf75sej2O7rs
qsCBoBAXot3ykQU5i947sV2N0nR28T6JbyS70oKTQu2xQofpMxf2ZxE020Ow7NPK
cX1ikC/GHgaBwgK7I2rmPhNhzyC7B449zQY8VROB85gHkom7zJKJ2bWJzEW76tg5
63SvNjaIrzuyLdYW7BLccwz7bKH2tWi6vLdqqXTUfGfCwLnTf4Aq9+BJVr1IDItB
Siz3nQWujKwpuAEOJwLaT6QVUxPlBGMtAdQEYa/aFHqmiSbXIPjLzAprDEBkRVSb
g7vtAklprf+iGzRiQleIrszQ7DuqU5DtOzhT4GGRa+HaCH/yfrhA5oa33hBvcwJ1
1OIDo3A32qIWtkzIesKvA6XfnpRyLB2ZI00EIU/N+pg22ATM1dt2pKNZtfWrtSCt
EWnLlST5jPO6wIjvecvsRCUtaBeV6J5s8t0mqCNYsuHAY7Gfib/Pu/dTPDX5EaJ7
BmMO+Ic/CPNnnxxzJFbt4vqusvz98qs1Af+gh1sApbYPTWUT3t1mwvobTOTC4oU/
GG2ke5P2HGyPfwZWtTlTFZiKm0933Xv2erbDMs4oN8dGRDfspaRMEAkCcHbxKBuF
ocGI2bNu0l8zDIY2LZyD9idE3GXFhtdNstVsRd7xcpKxb38ul4zIgnuG8L4cJC29
Z+lfM+h0rgIyVj9aQfjO
=3KF/
-----END PGP SIGNATURE-----

--=-KEqYOnV3MrudJGu99thh--
