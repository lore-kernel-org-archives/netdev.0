From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 11/16] c_can: stop netqueue if hardware is busy
Date: Mon, 09 Sep 2013 12:21:12 +0200
Message-ID: <522DA118.5020807@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-12-git-send-email-b.spranger@linutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="8S75qEI5wuusNeBLFwXEjWCSWG05BghA3"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57879 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab3IIKVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 06:21:20 -0400
In-Reply-To: <1378711513-2548-12-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8S75qEI5wuusNeBLFwXEjWCSWG05BghA3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
> Unlike other network devices the FlexCard do not support interrupts on =
TX.
> Emulate the TX interrupt by polling the MOTRX registers and restart the=

> netqueue if one or more message object is available for transtition of =
CAN
> frames.
>=20
> Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>

It's not onlynetif_wake_queue() that you have to call on TX-complete.
Have a look at c_can_do_tx(), better call it, or trigger napi from your
timer.

Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--8S75qEI5wuusNeBLFwXEjWCSWG05BghA3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItoRgACgkQjTAFq1RaXHN1oQCdHj9GrRQJKvyGq81FTUM4NEsM
cIsAmwRkTvEkSBVdV18ScC3xXDL0l07w
=lYPK
-----END PGP SIGNATURE-----

--8S75qEI5wuusNeBLFwXEjWCSWG05BghA3--
