From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH - regression 4.1-rc8] can: fix loss of CAN frames in
 raw_rcv
Date: Sun, 21 Jun 2015 18:57:44 +0200
Message-ID: <5586ED08.3000000@pengutronix.de>
References: <1434905444-11438-1-git-send-email-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="gHgWvjFfkDwfTOPrGsDkEfDNBJAGEJhn1"
To: Oliver Hartkopp <socketcan@hartkopp.net>, netdev@vger.kernel.org,
	davem@davemloft.net, manfred.schlaegl@gmx.at,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59463 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbbFUQ54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:57:56 -0400
In-Reply-To: <1434905444-11438-1-git-send-email-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gHgWvjFfkDwfTOPrGsDkEfDNBJAGEJhn1
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/21/2015 06:50 PM, Oliver Hartkopp wrote:
> As reported by Manfred Schlaegl here
>=20
>    http://marc.info/?l=3Dlinux-netdev&m=3D143482089824232&w=3D2
>=20
> commit 514ac99c64b "can: fix multiple delivery of a single CAN frame fo=
r
> overlapping CAN filters" requires the skb->tstamp to be set to check fo=
r
> identical CAN skbs.
>=20
> As net timestamping is influenced by several players (netstamp_needed a=
nd
> netdev_tstamp_prequeue) Manfred missed a proper timestamp which leads t=
o
> CAN frame loss.
>=20
> As skb timestamping became now mandatory for CAN related skbs this patc=
h
> makes sure that received CAN skbs always have a proper timestamp set.
> Maybe there's a better solution in the future but this patch fixes the
> CAN frame loss so far.
>=20
> Reported-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

I'll send a pullrequest to David asap, I'll add stable on Cc if this
doesn't make it into v4.1 anymore.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--gHgWvjFfkDwfTOPrGsDkEfDNBJAGEJhn1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJVhu0IAAoJEP5prqPJtc/HL/QH/0J9/CQWjhTcFYGYXPfzMM1N
OM1T0gFlI0Ocy9PPNY+tlK6D3r4RWsJgkwgirZPl69BUgLu8LCNeaFUpZgTnvvjU
eiUK1Ae508QN6QBEJTFvAtHp84oibcPHGVFvdtz6xvIf6ljyMCpS8rpBcKJmtNq6
/2/lAIZRlMg4mpg+UiGHA0GEyQlQ9jZn0SUoGJuE6qNW67giJiB2/eFV77dnLWYt
VcsetHvb8MkkZewRvoQaDMP102eZ+HFZzKW9ynzeLe7fGjM+e6uhtJbQItzntXeg
/wFNtQvgu2EoD9TmbP2ERg3N35Sp+IIDFQSDFU3m4XHF53Bs/hoYkmhPiujtsRc=
=K7pB
-----END PGP SIGNATURE-----

--gHgWvjFfkDwfTOPrGsDkEfDNBJAGEJhn1--
