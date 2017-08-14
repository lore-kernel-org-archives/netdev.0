From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configured if
 only I2C bus is configured
Date: Mon, 14 Aug 2017 08:20:48 +0300
Message-ID: <20170814052048.GC24282@mtr-leonro.local>
References: <1502385112-103765-1-git-send-email-ohado@mellanox.com>
 <20170812143715.GN24282@mtr-leonro.local>
 <VI1PR05MB1262B06790B2738CE1C0F889C88F0@VI1PR05MB1262.eurprd05.prod.outlook.com>
 <20170813.172521.1720357048468458417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="m9FEOsnejx470nED"
Cc: ohado@mellanox.com, netdev@vger.kernel.org, jiri@resnulli.us,
        saeedm@mellanox.com, vadimp@mellanox.com,
        system-sw-low-level@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:51266 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750878AbdHNFUx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Aug 2017 01:20:53 -0400
Content-Disposition: inline
In-Reply-To: <20170813.172521.1720357048468458417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--m9FEOsnejx470nED
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Aug 13, 2017 at 05:25:21PM -0700, David Miller wrote:
> From: Ohad Oz <ohado@mellanox.com>
> Date: Sun, 13 Aug 2017 15:26:56 +0000
>
> >
> >
> >> -----Original Message-----
> >> From: Leon Romanovsky [mailto:leon@kernel.org]
> >> Sent: Saturday, August 12, 2017 5:37 PM
> >> To: Ohad Oz <ohado@mellanox.com>
> >> Cc: davem@davemloft.net; netdev@vger.kernel.org; jiri@resnulli.us; Saeed
> >> Mahameed <saeedm@mellanox.com>; Vadim Pasternak
> >> <vadimp@mellanox.com>; system-sw-low-level <system-sw-low-
> >> level@mellanox.com>
> >> Subject: Re: [patch v1 1/2] Allow Mellanox network vendor to be configured
> >> if only I2C bus is configured
> >>
> >> On Thu, Aug 10, 2017 at 05:11:51PM +0000, Ohad Oz wrote:
> >> > Patch allows Mellanox devices on system with no PCI, but with I2C only.
> >> >
> >>
> >> Did you test mlx5 device on such system? Did it work for you?
> >
> > Yes, I did. With PCI config set to disable mlx5 drivers are not built.
> > Only the following:
> > /build/drivers/net/Ethernet/mellanox/mlxsw/mlxsw_core.ko
> > /build/drivers/net/Ethernet/mellanox /mlxsw/mlxsw_i2c.ko
> > /build/drivers/net/Ethernet/mellanox /mlxsw/mlxsw_minimal.ko
> >
> > While with both options on all drivers are built inc mlx5.
>
> I'm not so sure he's interested if things build or not.
>
> He's asking you if you actually used a Mellanox device with this
> driver with PCI disabled and only I2C available.

Thanks David, you are absolutely right.

The commit message and more important, Kconfig entry, is misleading the potential
users by promising them that all devices under drivers/net/ethernet/mellanox
folder are working with i2c.

I have no technical objection to the idea of this patch, but it needs to be resubmitted after
Ohad ensures that mlx4/mlx5 are not visible in menuconfig for i2c
systems and he fixes Kconfig description together with commit log.

Thanks

--m9FEOsnejx470nED
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmRMzAACgkQ5GN7iDZy
WKdEZhAArOyVVGChpgtpfTMauQDc/mLrd52IPbX7AI+8fpTegben3NwW5gNIsxDN
r797E5XZ9IjZR9dBZhfrbhf0NbNEEHseE/iMPRz41Qy3EesJisV12FZylbMHrN38
xh5lZyT7+UqyPYUp3hnEaj+DUkHkBTsI4OArOuZGJkRPKuVbbIG/jKdVkWLLt3XI
bFa91ubU5QmxcEwRo0Ya1zVuuSRfYo4P89ZbwCJ0uEgjZAPL2Z1JKCMK5VGgeEI3
e2doMIfhdWG8K7/9xWyNECORULbNZRVF73mfefkWjnEM9Q5YkzU9aBOqsDUcTOPP
FVGUWQJNj4T9fCxyyvqwvbwf6emotAM5+hOizPrfEjZ83irU+oZUzpm5hJ77KMGC
KkT7ElU9iTdJMWcl43TefOIe7r5bfWh13EnkC3y/lUd5pFz6DU5atHoqh/7yC4Fz
ldERFOWBrnkUjC46qBEd1Da8P0QbMp5t0B565TOOdmfdeXd0age92a5o8Xy5gr87
HO1enzgbBuCuLSWo8/4rgYDOPh3rjFM45lKar4T95UAB4Z5jpDaIilWMBwRW9c7Z
5zwC8QUzv6NyarqlAlkiP+c4FJucHSihu1r5Xd2t0yzjhVk7K/yCNxe7lCgh8V84
qqR6xg/RmM5yM9Kvmi3AigSGhaeQ8c6gQW5gf/Oed/zdYZTFzWQ=
=ewDO
-----END PGP SIGNATURE-----

--m9FEOsnejx470nED--
