From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -next] net: i40e: fix build, depends on CONFIGFS_FS
Date: Tue, 03 Mar 2015 12:23:56 -0800
Message-ID: <1425414236.2556.81.camel@jtkirshe-mobl>
References: <54F60D0A.6020903@infradead.org>
	 <20150303.150207.742456888724586407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wN4726QxVfpSfyPQT6ew"
Cc: rdunlap@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux.nics@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150303.150207.742456888724586407.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-wN4726QxVfpSfyPQT6ew
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-03 at 15:02 -0500, David Miller wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> Date: Tue, 03 Mar 2015 11:35:38 -0800
>=20
> > From: Randy Dunlap <rdunlap@infradead.org>
> >=20
> > i40e uses configfs interfaces so it should depend on CONFIGFS_FS.
> >=20
> > Fixes these build errors:
> >=20
> > drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
> > i40e_configfs.c:(.text+0x2fcdca): undefined reference to `config_item_i=
nit_type_name'
> > drivers/built-in.o: In function `i40e_configfs_init':
> > (.text+0x2fcee6): undefined reference to `config_group_init'
> > drivers/built-in.o: In function `i40e_configfs_init':
> > (.text+0x2fcf0c): undefined reference to `configfs_register_subsystem'
> > drivers/built-in.o: In function `i40e_configfs_exit':
> > (.text+0x2fcf71): undefined reference to `configfs_unregister_subsystem=
'
> >=20
> > Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>=20
> Intel guys, I am furiously mad.
>=20
> I've told you guys a thousand times to use portable, reasonable
> mechanisms to configure your hardware.  Using facilities that can
> be used for other cards from other vendors with similar facilities.
>=20
> If such portable netdevice configuration frameworks do not exist,
> create it.
>=20
> Every time you make a device specific mechanism for configuration,
> a small kitten dies somewhere in the world.
>=20
> Please remove all of this configfs crap for twiddling bandwidth
> et al. knobs, before I do it for you.

Sorry Dave, I did not see the configfs changes as being in the same boat
as some of the debugfs changes which were unacceptable.

I am working with Greg Rose and Jesse Brandeburg to address your
concerns with these recent changes.

--=-wN4726QxVfpSfyPQT6ew
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9hhcAAoJEOVv75VaS+3Op+MQAI2+mT8NbHJkwaW6ffFp1xkK
Z1cXc2IgzLI4AwMy6zBWySOJHRq68G0BRH0P8nvIvUK34VmpbpsOxkH5+t/icjj2
TEEpj0DqutXbRog1syM15YfvKmkY5jelKgT/FzBZAWqnogkwMZ1henhJVcCjhUCA
b0lFZCxMTAWDpRmRqye7B3z4JrgGMnfW4mYIu0JmerytOPeTGuvDKrBOlQk0VdoX
Xr4B5Hvo9UVP34mzSlMCB0o9l/oT6g3BV/gy5gGz0Mj9UJYRuq4PyfKbccO0+iVg
kSgXZeB9plDR/L0zu+nl/0Xj+ZBEsuSCQYqMWOKYGBh/TRVtpbUfURifkuB5UFra
H9mhSbV02sTO6jBFAMt9ctIaZ6VMgjePBOSenXqmMwGPxR6iWCXnP6fTIAaFBF2e
y078fEGIgFEa+KixU2wWI0OfWfFNWiJ0wRs70SPoNCG6qshNcd6yXCl96ybSg3ED
XlvRwD/nHQqilx8OF8+jNjmfyMFc37d5xuHet5Q9qHCJ7b3yg2Eu8ahiP40GUHLK
eTO1TAHburH1E0aXcY/k43AxtnmU/6wUrIjAUv4+i4frLEU8kMyO2wx83FPspm+7
Ye/CiOr4Us1rRxqW6SrqFG92qblVtjfp1ggU4IM9UXN+bllOr992dfVXeC9DAww1
u9j1oaRw+nYf2+4KlnmP
=acCI
-----END PGP SIGNATURE-----

--=-wN4726QxVfpSfyPQT6ew--
