From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 1/3] infiniband: rxe: avoid 64-bit division
Date: Mon, 13 Jun 2016 16:18:40 +0300
Message-ID: <20160613131840.GJ5408@leon.nu>
References: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nywXBoy70X0GaB8B"
Cc: netdev@vger.kernel.org, Moni Shoua <monis@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Kamal Heib <kamalh@mellanox.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465822509-4167617-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nywXBoy70X0GaB8B
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jun 13, 2016 at 02:54:53PM +0200, Arnd Bergmann wrote:
> The rxe driver fails to build on 32-bit because of a 64-bit division:
>=20
> In function `rxe_qp_from_attr':
> :(.text+0x53158): undefined reference to `__aeabi_uldivmod'
>=20
> We can easily avoid this division by converting the nanosecond value
> into jiffies directly rather than converting to microseconds first.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Thanks Arnd,
All three patches are applied on topic/rxe now.

--nywXBoy70X0GaB8B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXXrKwAAoJEORje4g2clinMkkP/39vV6Sq9NbTx7ZA2Kb16jmf
PDk0o51FSGtHpUeg2lD0PvPKvTcPPBH35o2kS333vMIdLifRys7nYgA83vBXaT2+
o9EX6FOve7Y6XFbPO8JZC2aIPMWCdSYHW/1UHSPdgiyTmliUiruJizdwsb95Rbn1
INJgZBX89bmjfkxj8KKGb7rr0ii2YwqcwW9zGMpSB+Qo9buVC8wrpFe5/u54DqKF
77n0FXlBFaLOMD2Jweu/FsxLADy0yu5IOLT6vU1drgsNQfI2wBEQYl1Ec/WZFpgO
QWz4etLY13d/g39BxegrQr3emqFZv6uJZ1+yyR3D6C1xNjAQeCLBT7e4fcytqptT
/9W62HBflHgG1uTLinDd84ON2jOdb5C1Ts5uGv6/zK+/Rpql77Qz+cP7ruHE9llF
m2bbFic9zak/I/pSIaJIMuPe5IL1SkoMxoNwIf64i/Nh48CmiuoBWYm/Irq+M3Qm
kenkqm3VbRgv71aHmVb+0SX0HmNBYQcjjisGRfoEj2g7GDDarP82bC+04Fa9wIaE
bay5qpiiwTsjvUy2XIIOIJ3fGFbABWDMZqd0H2OrBO1totXeFnW7ovyUWuK/U5rj
k00pO8TEGv+sWz+hdmyBWbrUbPkWRKDj4oUcVCcA5LubX2bksOWMOJE7xZYanaNI
cvcCvmVaOQxoZ7s4uIRn
=vNKR
-----END PGP SIGNATURE-----

--nywXBoy70X0GaB8B--
