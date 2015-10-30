From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: Use correct type in sizeof() in nla_put()
Date: Fri, 30 Oct 2015 14:40:26 +0100
Message-ID: <5633734A.3040504@pengutronix.de>
References: <1446209299-6250-1-git-send-email-marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="mrp4Hvtb2OXK7G8Aw5m2jXkdqM8rl5RT7"
Cc: Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Marek Vasut <marex@denx.de>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1446209299-6250-1-git-send-email-marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mrp4Hvtb2OXK7G8Aw5m2jXkdqM8rl5RT7
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 10/30/2015 01:48 PM, Marek Vasut wrote:
> The sizeof() is invoked on an incorrect variable, likely due to some
> copy-paste error, and this might result in memory corruption. Fix this.=

>=20
> Signed-off-by: Marek Vasut <marex@denx.de>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: netdev@vger.kernel.org

Applies to can and added stable on Cc.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--mrp4Hvtb2OXK7G8Aw5m2jXkdqM8rl5RT7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBCgAGBQJWM3NKAAoJEP5prqPJtc/HnxQIAJe5li9y/zpphTyMI5H9cC/J
frtIkft7Q21S084znrbo3rTKdf4uFQPDkmaGQwqKBvinc2ssVcpGeYXkpsYxCTN4
gl+Cs7ew76P3H6/piPEhJ2mUjPtRCDueesN7AmAetqgerOin31bOrA+22dRAcF8n
911D7DmFBGRHZvFJM99r0QRicwd3hhxH6ACYmuaH+J6eMh8KAjitoVz87vV1GnZK
emTymivo4nSc2YPfSDbSvDgUHwJrznOiVz39BhDEf+JC9hufEYjc1tqfJFM+i2mV
rvi803npD11rVL7BPD/mClaRHyD3oMHYduzWUrToGehughEyeRcbdVo2Zi8QEg4=
=Tnv+
-----END PGP SIGNATURE-----

--mrp4Hvtb2OXK7G8Aw5m2jXkdqM8rl5RT7--
