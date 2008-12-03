From: Luotao Fu <l.fu@pengutronix.de>
Subject: Re: [PATCH]  remove isa stuff from smc91x driver
Date: Wed, 3 Dec 2008 16:19:20 +0100
Message-ID: <20081203151919.GD5559@pengutronix.de>
References: <1228315701-17240-1-git-send-email-l.fu@pengutronix.de> <20081203145235.05e1f461@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="48TaNjbzBVislYPb"
Cc: Luotao Fu <l.fu@pengutronix.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40367 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbYLCPTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 10:19:21 -0500
Content-Disposition: inline
In-Reply-To: <20081203145235.05e1f461@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--48TaNjbzBVislYPb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 03, 2008 at 02:52:35PM +0000, Alan Cox wrote:
> On Wed,  3 Dec 2008 15:48:21 +0100
> Luotao Fu <l.fu@pengutronix.de> wrote:
>=20
> > From: Luotao Fu <lfu@pengutronix.de>
> >=20
> > ISA support in smc91x is incomplete. I doubt there're any smc91x isa ca=
rd.
> > This driver is greatly used on arm pxa platforms. Hence we remove the
> > isa stuff from smc91x driver.
>=20
> This makes no sense. It is protected by an ifdef anyway so doesn't affect
> ARM

The isa part in smc91x does nothing at all. Get you a unused variable warni=
ng if
you turn ISA on and compile it. The io table is defined and not used at all.
Neither does the io address and irq by parameter. I think that these are wa=
ste
code and should be removed.

Cheers
Luotao Fu
--=20
   Dipl.-Ing. Luotao Fu | Phone: +49-5121-206917-5004
Pengutronix - Linux Solutions for Science and Industry
Entwicklungszentrum Nord     http://www.pengutronix.de


--48TaNjbzBVislYPb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFJNqN3iruQY+UyUmERAt+ZAJ4tvdZxWreSNa5CT3QLOgVuec+7+gCeIGzq
TEVkR6eUO8HA5BgCIkeaBn4=
=Xt3q
-----END PGP SIGNATURE-----

--48TaNjbzBVislYPb--
