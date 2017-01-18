From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] softingcs: ret is never non-zero, so remove non-zero
 check and -ENODEV return
Date: Wed, 18 Jan 2017 15:44:53 +0100
Message-ID: <315e8833-1222-88bd-c806-e3688a37dab3@pengutronix.de>
References: <20170111150238.19845-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="GndtMIgVp6uOepqtOMnGO1cXlUVkhHcH3"
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Wolfgang Grandegger <wg@grandegger.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170111150238.19845-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--GndtMIgVp6uOepqtOMnGO1cXlUVkhHcH3
Content-Type: multipart/mixed; boundary="r09e9mQ3c2gLcCafopB83UGsHfqwLcQoL";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Colin King <colin.king@canonical.com>,
 Wolfgang Grandegger <wg@grandegger.com>, linux-can@vger.kernel.org,
 netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Message-ID: <315e8833-1222-88bd-c806-e3688a37dab3@pengutronix.de>
Subject: Re: [PATCH] softingcs: ret is never non-zero, so remove non-zero
 check and -ENODEV return
References: <20170111150238.19845-1-colin.king@canonical.com>
In-Reply-To: <20170111150238.19845-1-colin.king@canonical.com>

--r09e9mQ3c2gLcCafopB83UGsHfqwLcQoL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 01/11/2017 04:02 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
>=20
> The error return ret is never zero in the error handling path in
> softingcs_probe, so the check for non-zero and returning -ENODEV
> is logically dead code and hence redundant.  Remove it and just
> return ret.
>=20
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Thanks, applied to can-next.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--r09e9mQ3c2gLcCafopB83UGsHfqwLcQoL--

--GndtMIgVp6uOepqtOMnGO1cXlUVkhHcH3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEES2FAuYbJvAGobdVQPTuqJaypJWoFAlh/f2UACgkQPTuqJayp
JWotzQf/ScgjXP3W0fgQPHp1qR7TEc/LqdOK5VFmv50bO2Gsat6Ijfks7fvMj96e
jJtCXBWuLYBaUZic22TEp4xOhLHsXfIjOEFNkccnye29vdZAN4qTytKH/JijSx54
qPWy99bzotkaRE4vcnT/+r2/b6ZW/kQJptLhq0vEM5Wuaxx4hVjjZz3ZJf2/Ewdq
0u4TFDFQDoYS9/uRMnkWtS5GjRHnxaxf19kEBE3zyWMtOtJx/oSxnJTJqaw8l/TI
whcqL21rqb7B+WGq6WTBca0i1/zl2Zgsxfggwo+nCW0Nza6fOEwBKkUG0mDQhVUH
V03FSBdujbxdqap7VHLI9wQup643mw==
=Tn2v
-----END PGP SIGNATURE-----

--GndtMIgVp6uOepqtOMnGO1cXlUVkhHcH3--
