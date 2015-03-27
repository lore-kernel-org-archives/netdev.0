From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 0/2] ixgbe: Add the appropriate ethtool ops
 to query RSS indirection table and key
Date: Thu, 26 Mar 2015 21:17:58 -0700
Message-ID: <1427429878.2497.46.camel@jtkirshe-mobl>
References: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CByTi3dFVDvnuJWEE2r5"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19198 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751205AbbC0ESE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 00:18:04 -0400
In-Reply-To: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CByTi3dFVDvnuJWEE2r5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 00:44 +0200, Vlad Zolotarov wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection
> table
> and RSS Random Key.
>=20
> This series refactors the RSS configuration code to store the current
> contents of
> RSS indirection table and Hash Key in the "adapter" struct so that we
> won't need
> to access registers every time this info is queried.
>=20
> New in v2:
>    - Some styling fixes.
>    - Moved macros definitions from ixgbe_type.h to ixgbe.h.
>=20
> Vlad Zolotarov (2):
>   ixgbe: Refactor the RSS configuration code.
>   ixgbe: Add the appropriate ethtool ops to query RSS indirection
> table
>     and key

I am assuming that this series is to replace the latest v8 series,
correct?

--=-CByTi3dFVDvnuJWEE2r5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVFNn2AAoJEOVv75VaS+3O8wQP/1kXQq3QtU2Tjt6RxqV16Aez
9nWmcKFeV+IuIAanOxTFhXqLxF5Jsol+MVtLeFX2qGeoa2Z0JKhWChU6xUS+a0Mi
3fmJxEmFdBjYkZRJskKxzKQjvVNggPqbEs6zuQEEFXXTYEHhCQQZ/h7I3UJlbEPP
40wj4SzfqJN7CHmf9QLA8cO81+mYOrpvycVcDNpNRMdSN0jY+Mgoe+ZlkqBDm6gx
Xn6UxK3FTufcKZ8Rh82KArGi9Kr4nX06ux289nI1mUdcgXFXky2e7eww0cRvpw1y
4D4pHeGzw+U9evKAUZj4lP8MFxhARehXX7m0ZR2XrYcXbXeam+4RtZ06UE52cuLe
BLWXsX1mRyw5aVqV/x3v8aDO1q1Jq25kR0VEtDwyEI4Ir7T2wYPDJnJ+AKP5NuSI
DKhUyWGsuR/6dZJooCTW/j27CnB7FBCB+2nylFKytvJiRfU2FV1LbsfvVmO47b+p
/ownXWUy2EX9u/MVADJymcXUnAoOWBfVbqEp5QijtKWnTKKjis/ip/Xku8XpALXN
PJ/6H5capm3EspNshAgZ2OriDDtvyW4O0ncr7zLRuoaIXjltcircWOMbPxjdrFLd
jcfvTdj1MGW43X13oTJ8f03MN2U56icecaVudSM8D256gJ15CHGLSSqvclRSfqir
EI9xRuQPlQQR/0PYuBdm
=Exnh
-----END PGP SIGNATURE-----

--=-CByTi3dFVDvnuJWEE2r5--
