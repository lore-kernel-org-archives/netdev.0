From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net/fsl: remove dependency FSL_SOC from MDIO
Date: Sat, 14 Mar 2015 20:14:17 +0000
Message-ID: <1426364057.4173.115.camel@decadent.org.uk>
References: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-osc6E2dMpoU3mpbKMk+2"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53849 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752488AbbCNUO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 16:14:29 -0400
In-Reply-To: <1425983472-24629-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-osc6E2dMpoU3mpbKMk+2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-10 at 18:31 +0800, shh.xie@gmail.com wrote:
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>=20
> FSL_PQ_MDIO and FSL_XGMAC_MDIO are not really depend on FSL_SOC, they
> can build on non-PPC platforms.

If this hardware can actually be used on other architectures, fine.

If not, the dependency should be FSL_SOC || COMPILE_TEST so that the
option is only available on other architectures when developers want to
check that these drivers build.

Ben.

> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/ethernet/freescale/Kconfig | 2 --
>  1 file changed, 2 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/etherne=
t/freescale/Kconfig
> index ba84c4a..25e3425 100644
> --- a/drivers/net/ethernet/freescale/Kconfig
> +++ b/drivers/net/ethernet/freescale/Kconfig
> @@ -58,14 +58,12 @@ source "drivers/net/ethernet/freescale/fs_enet/Kconfi=
g"
> =20
>  config FSL_PQ_MDIO
>  	tristate "Freescale PQ MDIO"
> -	depends on FSL_SOC
>  	select PHYLIB
>  	---help---
>  	  This driver supports the MDIO bus used by the gianfar and UCC drivers=
.
> =20
>  config FSL_XGMAC_MDIO
>  	tristate "Freescale XGMAC MDIO"
> -	depends on FSL_SOC
>  	select PHYLIB
>  	select OF_MDIO
>  	---help---

--=20
Ben Hutchings
Q.  Which is the greater problem in the world today, ignorance or apathy?
A.  I don't know and I couldn't care less.

--=-osc6E2dMpoU3mpbKMk+2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVQSWnue/yOyVhhEJAQqYRw//fHXS++L9jzFLIheg+HPG1Xy1hDueq2gE
6D2qYpo1aAjNS/S/obr+Grt8iuqz5KzyS43ezWnGbMVcLL3QpvRy7/wDG1j3eeYV
44l0F90fJEO5LB4p2fMPSH8QrNxJ//QtLeKQ8evTh0FoH3f2jYUfYgn8J8G5Eoyw
BhfBxFcfTEfc7kUq7Nkt5noE0MMLGmLiOOtFLwzNqSKxxt2IS/g8Vso1eYeBeES5
SBg45tKNtCYEMV6z830ZAfOKYDQmUt7rgComVPagkxFou9je0Z+b8bIrWCi8xB9B
Md/5gk3UjMqzEiIiD2FA+TwXX/6kCKx6A1pBr0SOBqlg5WEvOG6+ElRHXEQakeCL
zOBnYevM8m/HibpEtMn1P9XsCsWRXK6/6JXFULTsqhz5WgyfYahj99tRI6zwfzuG
DeWkmD2ggM9TE6oSh0+m47DCaIihgkTpQesivmNxKr5JGmR+dzUgLf0IYmNzj/R4
pKuBp4/47uv33NVVqeQT/GEyYke0cwhrrDnjDOXWPWcr9z+oLQPojzGsuAZq+mcu
DUjdEHeIojUMVBpiecPsurWJdIvKxvcsjY+9YfJnmX+03FjrreX2fDrC2IlAS645
aXZnWJwzFpzgs+CMuqZB7lUlG+t7xVh64lDucR9WiXT7+rqHebOxscYpLj3W6eYH
qfSBqBQceH8=
=nBz1
-----END PGP SIGNATURE-----

--=-osc6E2dMpoU3mpbKMk+2--
