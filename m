From: Sebastian Reichel <sre@kernel.org>
Subject: Re: next-20170608 build: 1 failures 4 warnings (next-20170608)
Date: Thu, 8 Jun 2017 13:33:26 +0200
Message-ID: <20170608113326.zo3nqwkbx3k42owz@earth>
References: <E1dIuCM-0000cQ-QM@optimist>
 <20170608103231.gmqx6qluzcjwzrst@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="gsowus6vtznnoya2"
Cc: "David S. Miller" <davem@davemloft.net>,
        kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        netdev@vger.kernel.org
To: Mark Brown <broonie@kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608103231.gmqx6qluzcjwzrst@sirena.org.uk>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gsowus6vtznnoya2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Jun 08, 2017 at 11:32:31AM +0100, Mark Brown wrote:
> On Thu, Jun 08, 2017 at 10:57:50AM +0100, Build bot for Mark Brown wrote:
>=20
> Today's -next fails to build an ARM allmodconfig due to:
>=20
> > 	arm-allmodconfig
> > ../drivers/hsi/clients/ssi_protocol.c:1069:5: error: 'struct net_device=
' has no member named 'destructor'
>=20
> due to cf124db566e6 (net: Fix inconsistent teardown and release of
> private netdev state.) which missed this instance, presumably due to a
> combination of it not being in one of the normal networking driver
> directories and only being buildable on ARM.

I assume, that this will be fixed via the net tree.
If you Cc me on updated/new patch I will provide Acked-by.

-- Sebastian

--gsowus6vtznnoya2
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlk5NgYACgkQ2O7X88g7
+poAExAAhU/w20E5WhOsW34q9cKL636imVqYv9A0LVTD3DSINy01J0u3Nh30tOGN
hy/8hn5XJ5m/J2BnPSdfmXlEskJozOJ/xtoUb30cfOftB4Aq0Kr38jcfwxSXgVCd
NdZgS+aQxCPuw69nP7qbyXKWEVel55cQKSSARP3xcnY2JgaBdOK0xUn9VLy0o1bl
NSdxP24zvnkXi0Yk31uR5FrTIujw4E4Tzomrpure6oVZmU/K9QqfdbeoH8Bpgu4e
AQz6/baMGED8hAJJ7e5o1B3KlI4INs6CjqxKxXsgJrdAui3b7Stokq9TQc3RiUqR
R374rKQBHYjwF6WQI2ZFB2yQ7OzKaCeVEH87wpapvvDJ3EL69QmLqGY+uzih8n+l
gXh5BdLUO9ZRU+xtTDixFCyDKVrPi06dUbl9U/dQyu0jazIOwp0j7GSQGpLtV+/N
Dq+lGsQyzYZhZzz7nZE8W2WrX3yNHeV/SqDLWQhdH6sS2kXfTvTwhbozfk+TEPm+
sB2BjcDf6mZf16gSWZrTeODG8lCvnhNd/qwT9C9ZThzxwBmdy0weuixGcYfN4n5P
j5ajbFCx0iDHk7HrWTF8cJ3j1GpdPvDLR564uVlh5gl7B/o5TuvDuc6+267Y32xN
QRnBKnV4ziMSguBhN9K1Y2xRQvx3rJzJGnFXnSl5tKFkviOQ17w=
=5Ssi
-----END PGP SIGNATURE-----

--gsowus6vtznnoya2--
