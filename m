From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] e1000: fix time comparison
Date: Wed, 07 Jan 2015 14:02:26 -0800
Message-ID: <1420668146.2491.75.camel@jtkirshe-mobl>
References: <20150107124145.GA15954@ubuntu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+oxtYsOxydXCAh4ixckw"
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, matthew.vick@intel.com,
	netdev@vger.kernel.org, carolyn.wyborny@intel.com
To: Asaf Vertz <asaf.vertz@tandemg.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:17696 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978AbbAGWCl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 17:02:41 -0500
In-Reply-To: <20150107124145.GA15954@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+oxtYsOxydXCAh4ixckw
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-07 at 14:41 +0200, Asaf Vertz wrote:
> To be future-proof and for better readability the time comparisons are
> modified to use time_after_eq() instead of plain, error-prone math.
>=20
> Signed-off-by: Asaf Vertz <asaf.vertz@tandemg.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_ethtool.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)

Thanks Asaf, I will add your patch to my queue.

--=-+oxtYsOxydXCAh4ixckw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUrazyAAoJEOVv75VaS+3OFZIP/i9VM3l9tUGCA9Esmdy9NU7c
ZJ+JLgYrrmIld8MUJmb1UEX+AMM2hSKWqWOOeo3PIjeaMkkBoJhX0KzvPauzYSrm
PwPOlAZZNQjJTUfKC1a1pK74Fgc9UGY3k49UmpidWQnZ4F80ux3A/b7QK6UB6IK3
2bnEo2d115nGI365AyT/XFZCU0j45nzjPZUvzf/Qmo7Gszng06UD1QzMJ/P03ZYD
k3mMbiNWONpIZojn2qselsqWkyqufkkLPG6p1GsJbd7/e8JBEmsnHxWSCUYNQtNZ
tir29Rn75CmoS+KRrRZtex2XByrsU/eoOv9BXyiJzMKkq0ViJeRCqPVQa8hED4la
+ETRHBhYHO+xrKepBXOy2lTPB37zP1d0/k0vGSCgg3wHmG1uNtU4jo/waKhhSr7o
6rwzbgA1EUqu3IROwz9DJB7q3+H2DJTWV0MIBSR0nFFM612dBJUPSPq9AlPs+HmA
inwrS4HnQZ0V7surGERdPKkE0xnx9dl3Py1JATKVJDOAsKJ6zuvJKTSEOBDF+wiM
8bNayEjEWj8LzQu4N9gY4mFFW9OqdmaHsT8X9ErgZ88B3qML4HBzTKMAsL9ZNDVu
XW7e1Isrzpg4828VDYN7H80Ls2ylT9CedV6U6BaOXGFKIePvHnjcDJAhU8rcVD2f
t/KGVjP+u8aTU8eakVzw
=H+5k
-----END PGP SIGNATURE-----

--=-+oxtYsOxydXCAh4ixckw--
