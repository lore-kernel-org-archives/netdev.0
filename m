From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: Re: Re: [B.A.T.M.A.N.] [PATCH 6/7] batman-adv: Allow to use
 rntl_link for device creation/deletion
Date: Sat, 1 Dec 2012 15:54:20 +0100
Message-ID: <20121201145420.GN24115@ritirata.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
 <15221362.NFC3M7kpXE@sven-laptop.home.narfation.org>
 <20121201132802.GM24115@ritirata.org>
 <3895612.sgriB1OUoY@sven-laptop.home.narfation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YS7t75H5cNTCpbja"
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:26897 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab2LAOzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 09:55:22 -0500
Content-Disposition: inline
In-Reply-To: <3895612.sgriB1OUoY@sven-laptop.home.narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YS7t75H5cNTCpbja
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 01, 2012 at 02:39:26PM +0100, Sven Eckelmann wrote:
> On Saturday 01 December 2012 14:28:02 Antonio Quartulli wrote:
> > > Because this is the normal way to create virtual network devices (ple=
ase
> > > feel free to correct me).
> >=20
> > Well, I've seen different iface types using many tools, e.g. vconfig,
> > tunctl, brctl..
> > Not that this justifies the fact that we should do the same (imho havin=
g a
> > standard and unified way for creating interfaces would be the best opti=
on).
>=20
> The device creation and enslaving using vconfig, tunctl and brctl can be=
=20
> replaced using ip.

True.

>=20
> > But, to be honest, I think it should better discuss how to entirely
> > moving/changing the existent API to a "better one" or to a "new one",
> > instead of starting to maintain two of them from now on with no plan, d=
on't
> > you think so?
>=20
> I leave this discussion to the maintainers of batman-adv.=20

I started this discussion here because you are still part of them (even if =
not
listed in MAINTAINERS).

> Btw. removing the=20
> old one without a time of coexistence sounds like a bad move. And therefo=
re=20
> maintaining of both interfaces like it is done in other network devices s=
eems=20
> to be necessary.
>=20

Exactly, this is what I wanted to discuss as "a plan".
Anyway, I discussed about this together with the others and it seems
that a proper solution now is to wait before merging this patchset and fix =
the
current sysfs/rtnl_lock problem first. What do you think?

Adding a new API without fixing the current one doesn't sound like a good m=
ove.


Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--YS7t75H5cNTCpbja
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQuhocAAoJEADl0hg6qKeOyPMP/2SWSPTPih27EvIsVnWm6MQ0
sArs1aQUc4XmOXikG93B6IiFc5iEeDOmJ87JPHTBbKEFIqi0viri8g4u0BXIP0Yv
Nwn+9Kd1tBLoNbvlFJMBVjVIblmeltfVh8W2kjlj3l1t0UROYs2oRYrrfa3b5/T+
TUWSAPZaYLCJSM5gT37z1U/H6SvQaurHOwCvxc8I4VinEZyK3E7EB7Iar4A0UcLJ
mExlA3khDphSJ7tjg7rKcm+Gthk1+z4CxblX+/whKo7q5/dBh6T8wWtO9WQWH6Qr
Hxb/8WKqEyWqBNfJqYK5rLP/cCI7EGw4rPl0VHekDQXSt+Rps+nvLHwMXlUi0Xmj
ilnOSF5uBrPUSFje7REYBExdpp6zz6P2o0nwBY37U6kQhvTw2QNpz1fAzf2nbSwM
jrtJTBaw2LV7ppFn9UVG5WTYmHfEtZxelsKKt4MP0sgpQwE7tz3EHAefHGyiY1C/
sG107dr2PEIG5GkRpsOQg4kUpW9NtqjW8HLCGMFUrlyBcDJCIDpG7qvb4gXM3zMx
xOql5SqQIbz8ZHvpQ2rFQ9+eEQP6YuCmafLczA01Vy1jv0QSdAVnrkKd07449U3l
G3SNINVNs8Fa+FL3mMcRrlGSoj4xes20URjxBSlXDtXlFeMrb8iF/a8NKQWF2O+0
77YuHcl5y2OJ9JRaDhpx
=ye2Z
-----END PGP SIGNATURE-----

--YS7t75H5cNTCpbja--
