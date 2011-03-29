From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: BUG: ping without route segfaults in dst_release
Date: Tue, 29 Mar 2011 02:18:00 +0200
Message-ID: <4D912538.8080001@pengutronix.de>
References: <4D911758.3010608@pengutronix.de> <20110328.165149.193711805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF4306F711CC64A16B66CFEE8"
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34614 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755613Ab1C2ASI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 20:18:08 -0400
In-Reply-To: <20110328.165149.193711805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF4306F711CC64A16B66CFEE8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 03/29/2011 01:51 AM, David Miller wrote:
> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Tue, 29 Mar 2011 01:18:48 +0200
>=20
>> root@ptx:~ ping 130.75.1.32
>> PING 130.75.1.32 (130.75[   10.160000] Unable to handle kernel paging =
request at virtual address ffffffdb
>=20
> Well, that was easy enough :-)

\o/, ping works again.

> --------------------
> ipv4: Don't ip_rt_put() an error pointer in RAW sockets.
>=20
> Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: David S. Miller <davem@davemloft.net>
Tested-by: Marc Kleine-Budde <mkl@pengutronix.de>

g'night
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigF4306F711CC64A16B66CFEE8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk2RJT0ACgkQjTAFq1RaXHN8WACghFFrx7y3bcfUiegNJUPP9hPX
Jq0An0tL1s5vAA5A7kBF0sCnsGbgWUZq
=UrBw
-----END PGP SIGNATURE-----

--------------enigF4306F711CC64A16B66CFEE8--
