From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 3/5] ixgbe: Convert to use
 devm_hwmon_device_register_with_groups
Date: Mon, 25 Nov 2013 15:17:08 -0800
Message-ID: <1385421428.2270.15.camel@jtkirshe-mobl>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	 <1385186881-7931-4-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oUI0QQLclxRcq2Zba0eC"
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63974 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752732Ab3KYXR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 18:17:28 -0500
In-Reply-To: <1385186881-7931-4-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oUI0QQLclxRcq2Zba0eC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-22 at 22:07 -0800, Guenter Roeck wrote:
> Simplify the code. Attach hwmon sysfs attributes to hwmon device
> instead of pci device. Avoid race conditions caused by attributes
> being created after hwmon device registration. Implicitly
> (through hwmon API) add mandatory 'name' sysfs attribute.
>=20
> Other cleanup:
>=20
> Instead of allocating memory for hwmon attributes, move attributes
> and all other hwmon related data into struct hwmon_buff and allocate
> the entire structure using devm_kzalloc.
>=20
> Check return value from calls to igb_add_hwmon_attr() one by one
> instead
> of logically combining them all together.
>=20
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    8 ++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |   76
> ++++++++++--------------
>  2 files changed, 36 insertions(+), 48 deletions(-)

I have added this to my queue, thanks!

--=-oUI0QQLclxRcq2Zba0eC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSk9p0AAoJEOVv75VaS+3OYvEP/RM07jlWycrhE4k8YJddAxX2
8QoB7cPfHJF/rCwSzObGWPVO4QDR+NdkOKGErR8jhQzhhI4AVp+Nc92RAKcAKyx2
hVqGJQeIVXsU5OdTki3p7pSVNKZjEqz54z7LT809S16AJSvJMJJKB0gTWLo5zdS4
KuxOwN03tNvfTwPD68Jdh1l+iXCNRSpwceXIdqRSCUfAqQ3mYhlRsmnv8T+2Cpp4
285jCqYgeZbfW8gboKzLK4W1g192gTIvlYwAed00X0aPmByWZCI00ckj87m4nSNC
wu8RcEyvNvTbNWA1uZq/bmSTwQ25GdZaU2QvzHwANIo0UIPy95bwROTsezPpPwtG
8P5eiufXv9kiIkkXW5B8+nfaoNr60rwANZohuT6DxolMuAYqSpa/rvO9Z2HtTIDc
5EgK1PgdFAvtDCAd+B1Vf4IXw1UeszMPZZR2ruKtpDln4gBn6fHolGqEb4WxAt/H
HfNos1Yod0uG3qZN4n+uQ7JiJU/Ghmim8CRnORdQ0dml5xoFeOmBQtGb54YEQWmO
5QnzcECSl5ngugz7mBKWAzZMpJBHcx3Woe8tXXvtNdL9Gg/3WfCWs5Lq0gl5+Cm/
wZcMDntM8v23fWHhE8TYteyEHtV9Wy4F5WX9Jjx8GearFtWhT8c3b7qutXtI2G8L
/amh0NOwr5U3mvB6VBhK
=S5Fr
-----END PGP SIGNATURE-----

--=-oUI0QQLclxRcq2Zba0eC--
