From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH net 2/6] e1000e: Validate hwtstamp_config
 completely before applying it
Date: Thu, 14 Nov 2013 08:36:36 -0800
Message-ID: <1384446996.2160.4.camel@jtkirshe-mobl>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
	 <1384389698.29151.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-FnNhI3pr829kqFQbCSQM"
Cc: David Miller <davem@davemloft.net>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6279 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab3KNQgh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 11:36:37 -0500
In-Reply-To: <1384389698.29151.8.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-FnNhI3pr829kqFQbCSQM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-11-14 at 00:41 +0000, Ben Hutchings wrote:
> e1000e_hwtstamp_ioctl() should validate all fields of hwtstamp_config
> before making any changes.  Currently it copies the configuration to
> the e1000_adapter structure before validating it at all.
>=20
> Change e1000e_config_hwtstamp() to take a pointer to the
> hwstamp_config and to copy the config after validating it.
>=20
> Compile-tested only.
>=20
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

--=-FnNhI3pr829kqFQbCSQM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJShPwUAAoJEOVv75VaS+3OYSoP/1nGmh7mrEVNJa6sGFWwI4QB
acQY+uY4KX1+Cc0omgLHlQWqDrCcA1vlqwh4zGp1n779g7Q7mnBxV/yMNZajJMDw
fqv6kRSz6hvL35Xoe4fP612rDhoRg9R0wna37lINLGwIoTgVhbweODUvv9lr2zdg
qEWrJ1t/mjL3aa0xlB/DD6VKkxGRj+6y2dgDn1RGL/o7XIomAYPcvkklX/jAOpR7
NNL+0gxPvJLokWerDfDp1s5cWk7IYKqRgq17jDQSOAnduhkdVceCjqEJAJBQIYP3
jAXb2wm9NVNIiN9RPekwj08IyPAEv7xEbi2JB3txiaSr7xVUe9y4rU4+S7N8+8fA
+OiWaaaA+QYVlNvfwhi97f77cBWCu0/drOzd+MeQbMXexnbboGCV7mPpQQ0aun//
j/8Z6vXCTh3Xqzf7v4oUCW/EjB+4F6BrzmX3e0V+WpXFc2XlMpF6oUHbC6cy/71P
7Ob0CHRuJvc3jKat5QnIrsV60RavINcjTSLJkpCUeFWmVlYTci0DRl2E27cW9Sd3
svKl4/NgrYIjq1wscXug4osmqqANEbrHHhl8sdE82N/CAg2jA/zGuqKoRi8wGq9R
JAqP729csi43k3J/AOx9m3aJclqWYsXNUgMwwpZKZL5XH2LY4gEro/XTKR3yMvzT
zVY/hUJXNi813kH/fk8u
=7H8d
-----END PGP SIGNATURE-----

--=-FnNhI3pr829kqFQbCSQM--
