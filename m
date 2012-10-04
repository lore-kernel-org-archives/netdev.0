From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/20] drivers/net/can/sja1000/peak_pci.c: fix error return
 code
Date: Thu, 04 Oct 2012 11:31:11 +0200
Message-ID: <506D575F.4040402@pengutronix.de>
References: <1349281090-10013-4-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5BEFDC20CFC64095788A0E8A"
Cc: wg@grandegger.com, kernel-janitors@vger.kernel.org,
	davem@davemloft.net, jj@chaosbits.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:53634 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843Ab2JDJbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 05:31:21 -0400
In-Reply-To: <1349281090-10013-4-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5BEFDC20CFC64095788A0E8A
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 10/03/2012 06:17 PM, Peter Senna Tschudin wrote:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
>=20
> Convert a nonnegative error return code to a negative one, as returned
> elsewhere in the function.
>=20
> A simplified version of the semantic match that finds this problem is a=
s
> follows: (http://coccinelle.lip6.fr/)
>=20
> // <smpl>
> (
> if@p1 (\(ret < 0\|ret !=3D 0\))
>  { ... return ret; }
> |
> ret@p1 =3D 0
> )
> ... when !=3D ret =3D e1
>     when !=3D &ret
> *if(...)
> {
>   ... when !=3D ret =3D e2
>       when forall
>  return ret;
> }
> // </smpl>
>=20
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

Applied to can.
Tnx, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig5BEFDC20CFC64095788A0E8A
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://www.enigmail.net/

iEYEARECAAYFAlBtV18ACgkQjTAFq1RaXHPUhACfZftbepPARo5phiUlDFxBOlhZ
KCYAn3uW8Qr0gOg2wGr2nDG+Nf2mkV4/
=9Fva
-----END PGP SIGNATURE-----

--------------enig5BEFDC20CFC64095788A0E8A--
