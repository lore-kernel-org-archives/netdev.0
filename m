From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next] can: fix CAN BCM build with CONFIG_PROC_FS
 disabled
Date: Thu, 27 Apr 2017 09:52:39 +0200
Message-ID: <b8520a4a-0f1b-6410-f46c-1d0ca986bea3@pengutronix.de>
References: <20170426181434.9635-1-socketcan@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="1mkcIJgnT0Fpu5nviLpofNPpoGdGeqx1R"
Cc: netdev@vger.kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        linux-can@vger.kernel.org, davem@davemloft.net,
        rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:48157 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966017AbdD0Hwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 03:52:55 -0400
In-Reply-To: <20170426181434.9635-1-socketcan@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--1mkcIJgnT0Fpu5nviLpofNPpoGdGeqx1R
Content-Type: multipart/mixed; boundary="AbeWnrbnnI3TqV4hRNKhdvWMhnaVHPUuN";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>, linux-can@vger.kernel.org,
 davem@davemloft.net, rdunlap@infradead.org
Cc: netdev@vger.kernel.org
Message-ID: <b8520a4a-0f1b-6410-f46c-1d0ca986bea3@pengutronix.de>
Subject: Re: [PATCH net-next] can: fix CAN BCM build with CONFIG_PROC_FS
 disabled
References: <20170426181434.9635-1-socketcan@hartkopp.net>
In-Reply-To: <20170426181434.9635-1-socketcan@hartkopp.net>

--AbeWnrbnnI3TqV4hRNKhdvWMhnaVHPUuN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/26/2017 08:14 PM, Oliver Hartkopp wrote:
> The introduced namespace support moved the BCM variables for procfs int=
o a
> per-net data structure. This leads to a build failure with disabled pro=
cfs:
>=20
> on x86_64:
>=20
> when CONFIG_PROC_FS is not enabled:
>=20
> ../net/can/bcm.c:1541:14: error: 'struct netns_can' has no member named=
 'bcmproc_dir'
> ../net/can/bcm.c:1601:14: error: 'struct netns_can' has no member named=
 'bcmproc_dir'
> ../net/can/bcm.c:1696:11: error: 'struct netns_can' has no member named=
 'bcmproc_dir'
> ../net/can/bcm.c:1707:15: error: 'struct netns_can' has no member named=
 'bcmproc_dir'
>=20
> http://marc.info/?l=3Dlinux-can&m=3D149321842526524&w=3D2
>=20
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>

Applied to can-next.

Thanks,
Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--AbeWnrbnnI3TqV4hRNKhdvWMhnaVHPUuN--

--1mkcIJgnT0Fpu5nviLpofNPpoGdGeqx1R
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAlkBo0cACgkQHv7KIOw4
HPYy7Qf+M98SwsskCf0prHfGhdYmnMmNkXfyQSXRiNIdZ/CADEO0cY3mCQZSpHo/
FYlxzlXMsfwk4G5oVtv5lXXNpFEo6rqf2GqsvmDkW3/d//UrMoRXK7kyEzxuyuGB
ErSoef8PEW41bO5PfarECPwoDhFdTaoIXr+yXhWUgUrvOxCvAJKgWsJXWhNjT1OA
iSBF0JWKkYvh9rXoJ0HWhx2gHDBLe5A3846EQwD00nsaMUB96m9KsoL5o57DyIIt
pfUiNeoXiLIis/eTJZhFgs8GvNLYhWpXgXVQQZw/n/VEzev88PJaQMAdRfSRDvpM
1bREUYiwB5rMduUj8AcnzeicibPnNg==
=JU4b
-----END PGP SIGNATURE-----

--1mkcIJgnT0Fpu5nviLpofNPpoGdGeqx1R--
