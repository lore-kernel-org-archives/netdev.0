From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 12/16] c_can: Add flag to disable automatic retransmission
 of CAN frames
Date: Mon, 09 Sep 2013 12:34:15 +0200
Message-ID: <522DA427.2090008@pengutronix.de>
References: <1378711513-2548-1-git-send-email-b.spranger@linutronix.de> <1378711513-2548-13-git-send-email-b.spranger@linutronix.de> <522DA145.9090507@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="mIRwc74bdNR8ESrW5GoLgoJCoIGTrGW26"
Cc: netdev@vger.kernel.org,
	Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Holger Dengler <dengler@linutronix.de>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Benedikt Spranger <b.spranger@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:48036 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752408Ab3IIKeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 06:34:19 -0400
In-Reply-To: <522DA145.9090507@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mIRwc74bdNR8ESrW5GoLgoJCoIGTrGW26
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/09/2013 12:21 PM, Marc Kleine-Budde wrote:
> On 09/09/2013 09:25 AM, Benedikt Spranger wrote:
>> The C_CAN/D_CAN controler can automatic retransmit CAN after arbitrati=
on loss.
>> Add a flag to CAN ctrlmode set the appropiate behaivior of this featur=
e.
>=20
> We already have this flag, it's called CAN_CTRLMODE_ONE_SHOT.

BTW: Have a look at commit:

    ee6f098 can: c_can: disable one shot mode until driver is fixed

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mIRwc74bdNR8ESrW5GoLgoJCoIGTrGW26
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlItpCcACgkQjTAFq1RaXHNT8wCffEAGdeS7Q4F6jI4jD1guWDEC
d40Anj8pZxXuTy0gxRs7c61XVGLJ0G8j
=XKnA
-----END PGP SIGNATURE-----

--mIRwc74bdNR8ESrW5GoLgoJCoIGTrGW26--
