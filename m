From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] can: bcm: fix support for CAN FD frames
Date: Wed, 23 Nov 2016 15:35:32 +0100
Message-ID: <781efa22-a378-dd4c-97e1-9045eafd9121@pengutronix.de>
References: <20161123133325.1812-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="fgpiL6WF8hGjaDePglOKcxne3h7sWd9Sw"
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org,
        Andrey Konovalov <andreyknvl@google.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:41335 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S938655AbcKWOfi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:35:38 -0500
In-Reply-To: <20161123133325.1812-1-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--fgpiL6WF8hGjaDePglOKcxne3h7sWd9Sw
Content-Type: multipart/mixed; boundary="iCe7rsqAlkTpkFojCKaeFBeWNw9egHm8l";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org,
 Andrey Konovalov <andreyknvl@google.com>, netdev@vger.kernel.org
Message-ID: <781efa22-a378-dd4c-97e1-9045eafd9121@pengutronix.de>
Subject: Re: [PATCH] can: bcm: fix support for CAN FD frames
References: <20161123133325.1812-1-socketcan@hartkopp.net>
In-Reply-To: <20161123133325.1812-1-socketcan@hartkopp.net>

--iCe7rsqAlkTpkFojCKaeFBeWNw9egHm8l
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/23/2016 02:33 PM, Oliver Hartkopp wrote:
> Since commit 6f3b911d5f29b98 ("can: bcm: add support for CAN FD frames"=
) the
> CAN broadcast manager supports CAN and CAN FD data frames.
>=20
> As these data frames are embedded in struct can[fd]_frames which have a=

> different length the access to the provided array of CAN frames became
> dependend of op->cfsiz. By using a struct canfd_frame pointer for the a=
rray of
> CAN frames the new offset calculation based on op->cfsiz was accidently=
 applied
> to CAN FD frame element lengths.
>=20
> This fix makes the pointer to the arrays of the different CAN frame typ=
es a
> void pointer so that the offset calculation in bytes accesses the corre=
ct CAN
> frame elements.
>=20
> Reference: http://marc.info/?l=3Dlinux-netdev&m=3D147980658909653
>=20
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Added to can and send a pull request to David.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--iCe7rsqAlkTpkFojCKaeFBeWNw9egHm8l--

--fgpiL6WF8hGjaDePglOKcxne3h7sWd9Sw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlg1qTQACgkQPTuqJayp
JWqb9wf/eWIZ3XFFT0tcd8FA9fhE+qPKPwBj9bT0oAI3Rb5tbISZ8IrIzSKHRLlR
mEKaFy3VnXY7PFK7h/ou/NFwVRyjbLXnNnfiiPWpbxwDVdppBBPcX6h0RHJjw2fv
irInlUNA0aoApRqIffw3Jt1T4md2t797ZWw14IQxCHdh2POQW1Ti3NEPVRebTPN0
Sve8dTWYSb5566Q32S2fec2IX7lNP6Edjpd9qGYvQQb/NYS6nqmlEWs2rZXkvIBn
kCyP13gbLqy8BklMqMAKNMyLromVlC2BJZSwjsPMNPqz5gGQO5VoFmOAAFEAgfDl
k4MZg0X36bfbznxgCAe7cLAupyM5Ew==
=1F4I
-----END PGP SIGNATURE-----

--fgpiL6WF8hGjaDePglOKcxne3h7sWd9Sw--
