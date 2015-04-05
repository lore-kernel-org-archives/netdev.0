From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 2/5] ethtool: Add missing Advertised speeds
Date: Sun, 05 Apr 2015 03:13:19 +0100
Message-ID: <1428199999.11260.138.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-3-git-send-email-amirv@mellanox.com>
	 <1428197864.11260.121.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RjODedvOP+qZZOvQXOMj"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58739 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752092AbbDECNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 22:13:32 -0400
In-Reply-To: <1428197864.11260.121.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RjODedvOP+qZZOvQXOMj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-04-05 at 02:37 +0100, Ben Hutchings wrote:
> On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> > From: Eyal Grossman <eyalgr@mellanox.com>
> >=20
> > Added the following missing advertised speed modes:
> > - ADVERTISED_10000baseT_Full
> > - ADVERTISED_56000baseKR4_Full
> > - ADVERTISED_56000baseCR4_Full
> > - ADVERTISED_56000baseSR4_Full
> > - ADVERTISED_56000baseLR4_Full
> > - ADVERTISED_10000baseKX4_Full
> >=20
> > In order to reduce code duplication we added a macro to
> > ALL_ADVERTISED_FLAGS in line 88 ALL_ADVERTISED_MODES,
> > in addition the changed we made added speed that were
> > missing from ALL_ADVERTISED_MODES
> > (e.g. ADVERTISED_10000baseKX4_Full).
>=20
> Well spotted.
>=20
> > Added ADVERTISED_10000baseR_FEC to mode_defs.
> >
> > Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
> [...]
> > @@ -527,15 +516,20 @@ dump_link_caps(const char *prefix, const char *an=
_prefix, u32 mask,
> >  		{ 1, ADVERTISED_1000baseT_Full,     "1000baseT/Full" },
> >  		{ 0, ADVERTISED_1000baseKX_Full,    "1000baseKX/Full" },
> >  		{ 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
> > -		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
> > +		{ 1, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
>=20
> Why should this be on the same line as 2500baseX/Full?
>=20
> >  		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
> >  		{ 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
> > +		{ 0, ADVERTISED_10000baseR_FEC,     "10000baseR/FEC" },
>=20
> This is not a link mode, it's a separate capability that applies to all
> 10GBASE-R modes.  It's also meaningful for 40G and 100G modes despite
> the way we've named the flags.  Please put it in a separate section
> below the link modes.

I've applied this without the two bits I commented on.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-RjODedvOP+qZZOvQXOMj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCaROe/yOyVhhEJAQqmIxAApGa1YEe4IPdMz5cM9xSin9NI7LQ+gy0y
KjkBdIoh44rQZFjEHrD2bB1kkMReRo9bLQen9j7R8bnpgl7ML4EqcJeqmh2uWXBN
86V5OGX59NqM2EPad7qPaiu3SmHckSQsV+VtXuS6ERgdGHYG3syWiIGoOBkCrlYs
SGjSfGVHZT/Vc61X4x8//7oAoJ6SGKAkqddMhBTStXoSV2sAvEjSuegHoRG9ZKE6
MfkYv47rmWaasBVpBWbQbC65+ch+LOphmNOhauWedEc0/tFVvo/9o9FpJFDYNsDX
Eu/9zd7Ai4VHVVnu5g9aUgIoga6Wsa1jSY2U8or/pCxe5TFvenDEXSxm2pS+gtVQ
tjX55CR6Cq0wvrfEfgGiYJtqUd8Exbt/D+3VaQ7hKzmVYXax3ArmCT45Q9RJWV7o
rIlFqOSU1OUz2NKkoSJcNF5DFxz994t8mzz6r2kBIYUzJbrVTBtWpotwOf9Dcju4
zms+YBOsnsHgMeVPJuOYSWHAG5gPWlcS5H0Lhk2aKsRIHWJVZxfz+CXxiBQJ+jzm
t9Ot9m4diqWeR9mByFPRkL3oZ+xZhMq5x7AQZxshH1aV4Optjc4/yja6eFhQyUFT
GZQOXUh6KQSgmFthXp2I+yI/F9Jhc5mpDLJXSOLHBuu6SdE4B/TuCl1cE44946SY
rGNEchAEJo4=
=cpdS
-----END PGP SIGNATURE-----

--=-RjODedvOP+qZZOvQXOMj--
