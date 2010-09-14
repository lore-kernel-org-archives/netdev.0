From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Tue, 14 Sep 2010 09:08:48 +0200
Message-ID: <4C8F1F80.5050505@pengutronix.de>
References: <4C61EDE5.4030505@dsn.okisemi.com>	<4C629FE5.6000204@pengutronix.de> <005f01cb533e$5c21d530$66f8800a@maildom.okisemi.com> <4C8E1918.5000007@pengutronix.de> <003a01cb53a6$4ca724d0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB376FB62D7045DD117621BB1"
Cc: Wolfgang Grandegger <wg@grandegger.com>, arjan@linux.intel.com,
	meego-dev@meego.com, Morinaga <morinaga526@dsn.okisemi.com>,
	socketcan-core@lists.berlios.de, yong.y.wang@intel.com,
	gregkh@suse.de, netdev@vger.kernel.org, qi.wang@intel.com,
	andrew.chih.howe.khor@intel.com
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60182 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab0INHJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 03:09:08 -0400
In-Reply-To: <003a01cb53a6$4ca724d0$66f8800a@maildom.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB376FB62D7045DD117621BB1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 09/14/2010 02:46 AM, Masayuki Ohtake wrote:

>>>> - implement NAPI
>>> Since Topcliff CAN HW register has only single rx buffer,
>>> I think NAPI is unnecessary.
>=20
>> Doesn't matter. Please try to implement it.
>=20
> Our CAN driver must pull received data from CAN-HW rx buffer as fast as=
 it can
> so that the received data is not over-written by next received data.
> In case of implemented with NAPI,
> since NAPI has time-lagging after receiving first packet,
> probability of over-written(discarded) buffer is to be high.
> Thus, for our CAN HW, we should NOT implement with NAPI but normal "net=
if_rx".

Okay, point taken.

Regarding the one and only rx buffer. Is it a driver or a hardware
limitation?

BTW: Are the datasheets of this CAN core available somewhere?

cheers Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigB376FB62D7045DD117621BB1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkyPH4UACgkQjTAFq1RaXHODoACeJqeVrDA9Ie942MNE6MHH0XvK
qVoAnRDVzC7qIJ6lcZI2hbAlVuLtHdBT
=hDvx
-----END PGP SIGNATURE-----

--------------enigB376FB62D7045DD117621BB1--
