From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] net: drivers/net/hippi/Kconfig should be sourced
Date: Tue, 08 Nov 2011 12:40:24 -0800
Message-ID: <1320784825.4829.13.camel@jtkirshe-mobl>
References: <1320784270.14409.404.camel@x61.thuisdomein>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o+0bKM9+vRYAR7mC2V4y"
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320784270.14409.404.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-o+0bKM9+vRYAR7mC2V4y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2011-11-08 at 12:31 -0800, Paul Bolle wrote:
> Commit ff5a3b509e ("hippi: Move the HIPPI driver") moved the HIPPI
> driver into drivers/net/hippi. It didn't source
> drivers/net/hippi/Kconfig though, so it didn't make all necessary
> Kconfig changes. So let drivers/net/kconfig source HIPPI's Kconfig file.
>=20
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> git grep tested only. Perhaps the exact spot where
> drivers/net/hippi/Kconfig gets sourced is relevant, so this needs
> (build) testing by people actually familiar with the HIPPI driver.=20
>=20
>  drivers/net/Kconfig |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 583f66c..654a5e9 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -245,6 +245,8 @@ source "drivers/net/ethernet/Kconfig"
> =20
>  source "drivers/net/fddi/Kconfig"
> =20
> +source "drivers/net/hippi/Kconfig"
> +
>  config NET_SB1000
>  	tristate "General Instruments Surfboard 1000"
>  	depends on PNP

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>


--=-o+0bKM9+vRYAR7mC2V4y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOuZO4AAoJEOVv75VaS+3O8JoQAI7CmXOAI5+txJioPIjdgVJZ
Jtf11kUvMw87KUo4dxq5icOBi4Ci70cpmDq8v16y2Be+I57nNx85VtAQrYiqHyIG
xGmdKKcSUXCepxGmw3LwFR9CwrASqvafBEPFpiGZoq6+XRYrOs/p+mr18vSa18kr
fuDIVDe5xoA7XIu4HHdaEezzisLAgN1evewS+7N5rkXqu0rUwu9AZvhu0g3z5jAn
ByGL/k9mEKCI+8Qx+Gvxf8ErRtyjYaLVl8ZyMVZt9GE/FrfCEOac+NAe8sT0txBm
f64pCUwJbeXfImRPW5iXr8n04MHTPSWJsD9KpWLSERscHAaNuRI+hs4ZpHAXrtuQ
Kgm7cIqfoaLJBo6nVQF+M7AjPKMWBiuaEy3CrR0T1gRkKQSYJIRY3qxHOXQ6voe6
/QaPWYM9iNKVoHJ1CdJ0XNdvsKQyIdKNKl4Ulu1KtSxKBIfQ2JogUTUFdFtt+eoj
fiu9gjBFYEoG1RyjXokEdxGU3ZkF/dNjBsvZnc8re3jpJQhE1u7AQlHzemMmcpVd
m0/GUQf3nYpZ8ylOEQ5HIaywj/qO+bsIvc/JFV/zkS/C77MdveUzhtRaY+7spSvW
7+2xoLVz0eKENu2ZajB6LDq6Omg6i7vyfuBhutC0eMClIpzVYhxw3tyjVlelB5CP
9xmpwluK14UiLNpmAiMN
=sIrU
-----END PGP SIGNATURE-----

--=-o+0bKM9+vRYAR7mC2V4y--
