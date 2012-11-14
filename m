From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCHES] Networking fixes for -stable.
Date: Wed, 14 Nov 2012 16:34:56 +0000
Message-ID: <1352910896.4867.27.camel@deadeye.wl.decadent.org.uk>
References: <20121112.002558.46179003870204789.davem@davemloft.net>
	 <1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
	 <CA+MoWDqOd_0jOvFpqkqtSePRV--O8A2tfG71d_VpkUfN89Q_FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-YW6ICPY750MTyeTO1/ay"
Cc: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	stable@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59681 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422671Ab2KNQfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 11:35:09 -0500
In-Reply-To: <CA+MoWDqOd_0jOvFpqkqtSePRV--O8A2tfG71d_VpkUfN89Q_FQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-YW6ICPY750MTyeTO1/ay
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-11-14 at 15:02 +0100, Peter Senna Tschudin wrote:
> Hi Ben,
>=20
> On Tue, Nov 13, 2012 at 8:51 PM, Ben Hutchings <ben@decadent.org.uk> wrot=
e:
> > On Mon, 2012-11-12 at 00:25 -0500, David Miller wrote:
> >> Please queue up the following networking bug fixes for
> >> 3.0.x, 3.2.x, 3.4.x, and 3.6.x, respectively.
> > [...]
> >> From 2204849a85383fbde75680aa199142abe504adbb Mon Sep 17 00:00:00 2001
> >> From: Peter Senna Tschudin <peter.senna@gmail.com>
> >> Date: Sun, 28 Oct 2012 06:12:01 +0000
> >> Subject: [PATCH 7/9] drivers/net/phy/mdio-bitbang.c: Call mdiobus_unre=
gister
> >>  before mdiobus_free
> >>
> >> [ Upstream commit aa731872f7d33dcb8b54dad0cfb82d4e4d195d7e ]
> >>
> >> Based on commit b27393aecf66199f5ddad37c302d3e0cfadbe6c0
> >>
> >> Calling mdiobus_free without calling mdiobus_unregister causes
> >> BUG_ON(). This patch fixes the issue.
> > [...]
> >
> > This introduces a regresssion, as mdiobus_unregister() is not safe to
> > call if the bus isn't registered.  Registration is controlled by the
> > drivers that use mdio-bitbang, and they should take care of
> > unregistration too - and most of them do.
>=20
> Is mdiobus_free() safe to call if the bus isn't registered?
[...]

It must be, otherwise what do you do if mdiobus_register() fails?

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-YW6ICPY750MTyeTO1/ay
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUKPIMOe/yOyVhhEJAQpnaBAAoi3vs0yF8gpmZvA2AExRsINGT5QoGtCX
WgWJcy5MaUanz/NISUq7mqZkpZyRoB6gjPLMUuooPVhaeFZD0LUXRJ+FnbFpr44D
YB4eKvLPXBS4ciDuriih487aJYo3+U3FSM9S6/HKyNAf7GSYjIJ5jw0H5H85WWgW
YaVKPUQ7rsh868Z+osuYY5719ICRAnZWiUzY9gVgm8EiHutgxooCuZ+PWw142+rv
b0eCo0rOS3KEZKAzg34LkAbYQ0iVl1VIDgcPqa9nXN8a2r3b5Mp2f5lc/pYGv/eJ
D5g3Qn1+nSwxNI1Z0IYuZvt6iva9IsdBtqr4bekt+tjkXp5cb/F3ROat/2Dp1gzP
PxyVbO/lGqeAAQ4fpSApC+FkVyqZXtFeZLukb9v63yL4LNGf7lqhQZHLTjtJqXiN
y9bnHfzGd7f+CxztxyH3rTgThPNMnyoaHkpMpIk8GExpTcdPrJglQ3TXiVaZ780m
QIY5i0IypVNzjciyQizw4xfgcy5T4WpzBuzLG6Ep+G6fNHEGk5iM1JJKX6JUP7lM
Nu60rgm92pDm+F6Z8K8roI+pdQnuiCQz92MhVHPnQXAplXUtlzkvTmffV/5FH+54
8EzZy6MlwV7D8T9/LpchP8HHMbBThH+LWJVUJQC/R2o1MVwAXliXiTI9Ub7StrJk
LUHYy6Fc7f0=
=f602
-----END PGP SIGNATURE-----

--=-YW6ICPY750MTyeTO1/ay--
