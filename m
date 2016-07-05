From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 2/2] net: ethernet: bcmgenet: use
 phy_ethtool_{get|set}_link_ksettings
Date: Tue, 05 Jul 2016 23:40:10 +0200
Message-ID: <1467754810.4204.17.camel@decadent.org.uk>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
 <1467560037-21784-2-git-send-email-tremyfr@gmail.com>
 <20160704.160300.953705748553101659.davem@davemloft.net>
 <577B37CC.80807@gmail.com> <577C2189.8090604@gmail.com>
	 <577C2380.4000007@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-PlkL4GuuVtbsZy5EyntM"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42062 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755425AbcGEVkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 17:40:21 -0400
In-Reply-To: <577C2380.4000007@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PlkL4GuuVtbsZy5EyntM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-07-05 at 14:15 -0700, Florian Fainelli wrote:
> On 07/05/2016 02:07 PM, Philippe Reynes wrote:
> > Hi Florian,
> >=20
> > On 05/07/16 06:30, Florian Fainelli wrote:
> > > Le 04/07/2016 16:03, David Miller a =C3=A9crit :
> > > > From: Philippe Reynes<tremyfr@gmail.com>
> > > > Date: Sun,=C2=A0=C2=A03 Jul 2016 17:33:57 +0200
> > > >=20
> > > > > There are two generics functions phy_ethtool_{get|set}_link_ksett=
ings,
> > > > > so we can use them instead of defining the same code in the drive=
r.
> > > > >=20
> > > > > Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
> > > >=20
> > > > Applied.
> > > >=20
> > >=20
> > > The transformation is not equivalent, we lost the checks on
> > > netif_running() in the process, and those are here for a reason, if t=
he
> > > interface is down and therefore clock gated, MDIO accesses to the PHY
> > > will simply fail outright and cause bus errors.
> >=20
> > Oh, I see, I've missed this. Sorry for this mistake.
> > We should revert this path.
>=20
> Well, maybe better than that, actually put the check in the generic
> functions, because if the link is down, aka netif_running() returns
> false, link parameters cannot be reliably queried and they are invalid.

Either the hardware or the driver needs to remember:

- Is auto-negotiation enabled
- If so, which modes are advertised
- If not, which mode is forced

And it should still be possible to get or set that information when the
interface is down.

Ben.

--=20

Ben Hutchings
Life is what happens to you while you're busy making other plans.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0- John
Lennon

--=-PlkL4GuuVtbsZy5EyntM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXfCk6AAoJEOe/yOyVhhEJlLYP/38s/T7EfXj9RzPhJBE5Nk5o
84BKgUQvxRxTjDaf4AZpW9id9JiFsOhkI618cT54JWNnpIUJWP2aTmq/QEcaH6ok
wSi+lB35wVjkqzynxorv996TE1vZ2hbyYxFUpnQUh9yWrtcVd/QcT995+PI8Vrqa
2tJTiPgf8bxz3V0RJ/6lZczkUWT0mmFTW89MsF+6yMa3lNVkYCppa0dRTfHp51qF
2tOdCIKdp2BYMPv1ZeIUnzzblPaWWY9QeNEgKeVn3t/7OKrqkGH1jqDn1WO03LNa
7akwtuqc4zqzU6WEI0yFNQ+pbcyxUIQSR8dmILwciF/0M3mJCTKodXVpLMnDWGbO
NlM/XJwRqU+54tGw0v5+mDVO6auA3up7sZozouBkE52DTiUeFYzoWu15rr7GtAqf
Lg61xmdEF92oYEi8teiUOK9hIqN9svpcKuwJwSzZ8hKAO9LjWONdoUsFP+v+tOcd
YT3whuOAJ6VztpyyqCuBtzr+6dK0uzQMw+S0lHPAnWdsCZ2Vsvpy385LFt84Wf0L
/Ow40pwORcgbOOScI6jUudlS68Nh2TpX9GNJoUrFRSG6FtmImQcikd3L94nh5hTq
csQwUQD0rkAcc3xBJaz1YSO1RhwJMUOf4834M4vrZfjAn2pZk/JU/O/c0E2d4m+Z
sqWi1Vk2XbCwsJhu238n
=tgZB
-----END PGP SIGNATURE-----

--=-PlkL4GuuVtbsZy5EyntM--
