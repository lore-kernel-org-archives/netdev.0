From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH -next] net: i40e: fix build, depends on CONFIGFS_FS
Date: Tue, 03 Mar 2015 12:11:10 -0800
Message-ID: <1425413470.2556.78.camel@jtkirshe-mobl>
References: <54F60D0A.6020903@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ov/95F+K6b94YMsFgdaE"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux NICS <linux.nics@intel.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F60D0A.6020903@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ov/95F+K6b94YMsFgdaE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-03 at 11:35 -0800, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
>=20
> i40e uses configfs interfaces so it should depend on CONFIGFS_FS.
>=20
> Fixes these build errors:
>=20
> drivers/built-in.o: In function `i40e_cfgfs_group_make_item':
> i40e_configfs.c:(.text+0x2fcdca): undefined reference to
> `config_item_init_type_name'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x2fcee6): undefined reference to `config_group_init'
> drivers/built-in.o: In function `i40e_configfs_init':
> (.text+0x2fcf0c): undefined reference to `configfs_register_subsystem'
> drivers/built-in.o: In function `i40e_configfs_exit':
> (.text+0x2fcf71): undefined reference to
> `configfs_unregister_subsystem'
>=20
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc:     Linux NICS <linux.nics@intel.com>
> Cc:     Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/Kconfig |    1 +
>  1 file changed, 1 insertion(+)

I have a patch from Greg Rose already that fixes this, which I was just
about to push.

--=-ov/95F+K6b94YMsFgdaE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU9hVeAAoJEOVv75VaS+3O5akQAIaEiy3f3Kh3oeUtT6WPXHIq
3eMfbxUs2e+5Afqpc8gjdpO6puw4h6v72DD4EW7MA/NuySGbYSWRDf1TSnR2vT0l
yYhDSw+UGNLstxo97W/CVvLuXMC15Zaroh62+vl8YNT/meQh+NXrcxfU3H9yVx2C
yMaWt2+pqftwuR9BvwcliB3MVm3I8JF4QZIq30SO5t8kEK5DUCq03fEavxqav6tI
SRVErI9dn19L5SsDEHmp62n0Sb97BmzMkncGKZ6sqCh8fG7iZvywHy1li7y5Ds56
vWjxKadcvqVgxcLhZWrjpSo8N67+tgwihsIzlfQo7nB6WPa2vT8+DrIADkg1qa18
QdzLWK6G9WfBZx1mcEjALmLrn+DmptMzPmvT/09iDSRm7A0+rLbkg4vYyUe6HhJL
FWyrnamvmKVvqv2miB/H58Ao/cJrm9Mus2TXX/L+c/Ox95RCdmQN0OMJXCDCIos3
/XHe1gQdwNNXFmAB+qIF02bJq1wPUyPw8Dtxm5+jL5Rscgpu/W082pT8KWPreDsY
15nrCjTJrNpfoqr3efL/Bk9twtm1Cn8kKujjLxFujKn3GeARjYgo5ZIIAgrVr0t8
1Pt72CDttAE0uaqgchsF46gd2JUoVk1PyavYGD49IoT9Z4hbvXhmqZXPhbIw+jjl
bI6EGYdvd+l0EaJrZkL+
=/AL7
-----END PGP SIGNATURE-----

--=-ov/95F+K6b94YMsFgdaE--
