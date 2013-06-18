From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 1/3] net: Move MII out from under NET_CORE and
 hide it
Date: Tue, 18 Jun 2013 03:02:02 -0700
Message-ID: <1371549722.2133.145.camel@jtkirshe-mobl>
References: <1371522107.3495.61.camel@deadeye.wl.decadent.org.uk>
	 <1371522291.3495.63.camel@deadeye.wl.decadent.org.uk>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-c/Las1cZelioSGkO1vyN"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:29053 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072Ab3FRKCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 06:02:24 -0400
In-Reply-To: <1371522291.3495.63.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-c/Las1cZelioSGkO1vyN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-06-18 at 03:24 +0100, Ben Hutchings wrote:
> All drivers that select MII also need to select NET_CORE because MII
> depends on it.  This is a bit ridiculous because NET_CORE is just a
> menu option that doesn't enable any code by itself.
>=20
> There is also no need for it to be a visible option, since its users
> all select it.
>=20
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  arch/cris/arch-v10/drivers/Kconfig             |    1 -
>  arch/cris/arch-v32/drivers/Kconfig             |    1 -
>  drivers/net/Kconfig                            |   10 +++-------
>  drivers/net/ethernet/3com/Kconfig              |    1 -
>  drivers/net/ethernet/Kconfig                   |    4 ----
>  drivers/net/ethernet/adaptec/Kconfig           |    1 -
>  drivers/net/ethernet/adi/Kconfig               |    1 -
>  drivers/net/ethernet/allwinner/Kconfig         |    1 -
>  drivers/net/ethernet/amd/Kconfig               |    2 --
>  drivers/net/ethernet/atheros/Kconfig           |    4 ----
>  drivers/net/ethernet/broadcom/Kconfig          |    2 --
>  drivers/net/ethernet/cirrus/Kconfig            |    1 -
>  drivers/net/ethernet/davicom/Kconfig           |    1 -
>  drivers/net/ethernet/dec/tulip/Kconfig         |    1 -
>  drivers/net/ethernet/dlink/Kconfig             |    1 -
>  drivers/net/ethernet/faraday/Kconfig           |    1 -
>  drivers/net/ethernet/freescale/fs_enet/Kconfig |    1 -
>  drivers/net/ethernet/icplus/Kconfig            |    1 -
>  drivers/net/ethernet/intel/Kconfig             |    1 -
>  drivers/net/ethernet/micrel/Kconfig            |    4 ----
>  drivers/net/ethernet/nuvoton/Kconfig           |    1 -
>  drivers/net/ethernet/oki-semi/pch_gbe/Kconfig  |    1 -
>  drivers/net/ethernet/packetengines/Kconfig     |    1 -
>  drivers/net/ethernet/rdc/Kconfig               |    1 -
>  drivers/net/ethernet/realtek/Kconfig           |    3 ---
>  drivers/net/ethernet/renesas/Kconfig           |    1 -
>  drivers/net/ethernet/sgi/Kconfig               |    1 -
>  drivers/net/ethernet/sis/Kconfig               |    2 --
>  drivers/net/ethernet/smsc/Kconfig              |    5 -----
>  drivers/net/ethernet/stmicro/stmmac/Kconfig    |    1 -
>  drivers/net/ethernet/via/Kconfig               |    2 --
>  drivers/net/usb/Kconfig                        |    4 ----
>  drivers/staging/silicom/Kconfig                |    1 -
>  33 files changed, 3 insertions(+), 61 deletions(-)=20

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-c/Las1cZelioSGkO1vyN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRwDAaAAoJEOVv75VaS+3OvecQAJrZGXwU/vZQJDjzUDbWxtOU
20zc5SG2yiuaEtHgsRrJAwZq1Dm23PnhbL1LjRQXqfAbbkhXn90jO3aF0fOUIW5Z
IQ6LhYXOuzo+bxr41GWy48doxBPZNh/kROxS/N8ZNI6pd7CRpLlFu+ojhVGRBEBh
58UEnmxIkuUOTQTvyK+uBLF3VJ73FvJIbrsa8xV7l9dYdOwBNGsGkTLcjkioYGYM
kq6h5IrhG0FFbOSZUnresR2aJEWW4fNj/MRTrvC6Twh8mzfmSPnWycmX9bG/GF1v
dEHSKRrnJopZ9SSROxwU9xsP6jzQYDbgjMAVCllj29+jap6jMPfBQZRnCa6z4IK9
SwUMOOZpRfhFFbmrEMxAvlZLeUqUYpyesva0kt5w/JeTOclEfe8y6jcNPLA6d7pU
sOjxw5L1Oia+Z6UpiXkyVolTOcLqD7MJwu+jOlxtVt5t7a2p7ufv//C/ikEwBD+3
KhSlSj952PmY2bVfXtEhjd73YqwH5876x9s++qGj9JmcOYf5JM7hbJpzDdh3v9Ih
QeUoj6BC1RztsYQD16gGAQMzEN/8s87EB51wtflxgCpBTJ4BCop2L5wOwW8f0uM/
TWMEFBuD1q1IExhWKHccNo/IbPbvJY4VP2AJ0xLVIBFF4aeUXeDCfK2O1S3Bemkl
4fa9lTQya4+3TkSOVcUJ
=YaIK
-----END PGP SIGNATURE-----

--=-c/Las1cZelioSGkO1vyN--
