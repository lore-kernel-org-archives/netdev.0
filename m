From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/5] igb: Convert to use
 devm_hwmon_device_register_with_groups
Date: Mon, 25 Nov 2013 15:16:37 -0800
Message-ID: <1385421397.2270.14.camel@jtkirshe-mobl>
References: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
	 <1385186881-7931-3-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-zTC7tvhG9HrXTPzUwtwI"
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
Received: from mga02.intel.com ([134.134.136.20]:24831 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753290Ab3KYXQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Nov 2013 18:16:39 -0500
In-Reply-To: <1385186881-7931-3-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zTC7tvhG9HrXTPzUwtwI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2013-11-22 at 22:07 -0800, Guenter Roeck wrote:
> Simplify the code. Attach hwmon sysfs attributes to hwmon device
> instead of pci device. Avoid race conditions caused by attributes
> being created after registration and provide mandatory 'name'
> attribute by using new hwmon API.
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
>  drivers/net/ethernet/intel/igb/igb.h       |    8 ++-
>  drivers/net/ethernet/intel/igb/igb_hwmon.c |  100
> +++++++++++++---------------
>  2 files changed, 53 insertions(+), 55 deletions(-)

I have added this to my queue, thanks!

--=-zTC7tvhG9HrXTPzUwtwI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAABCgAGBQJSk9pVAAoJEOVv75VaS+3OhA4P/14Kyd1XgPHqBp5olLOsfnQ5
vZnKEvWxDkriOmIt+KuaQlVPMUU6g5pJ8DREbmp+XcV+PuA/sWVLhdnJa5Xt0QNq
6g9MD1KBDspH5uJ6N6ekH1BZm87k2d15ejskm7j0XHVStkZ4pz8yN17hQnz9kG4C
oEXPTXW17zXDpScamn8b/C+12Ig2QAsonB39utHV8ZW9BrJPWt0P/z/h80itStyL
IxTOR1GYGPM4ZK0ZcTje6jerJjRPgPoUthF/FSLZs5Ewoa+Hlf6+z7eq/2yIW7T6
lJrDFxdgy9N6VGk1FAvA5bAg6Bt1GnxU8gvI+9bLlP3jvofXncaAxgd2JAcdM2iu
Vgr0VsGQ/QBYt/iW9jPCiC+9oAOtYKo36kulkH2igyWjfjvAjLnAcnEdehNW5Qit
QMYFiSOsbWHeBvASaFWV1ToN0D6c999POPaYnb1+5d6T/a9HXW8gxm1qI7sHvbNG
mTd8Pxjeibga6T1lBiQrhYmupHVswYLbmT8Dr2zPMf056Gu3zGo35HctvaHEPXAP
so0Lm8/R1yyOmXLuh1pOZrD8PPAmdX3ajfA63R8hmd5w6e5S+mJ6J20q2Y7nSzfO
r+VZZNX+kN4L5voHYGUGT4rZcE0T8yh9IJR4mVu9rCj8sIiDR8uVgOkHJfek6fgO
J3w1F0VonRdMA0pOXAre
=vBHb
-----END PGP SIGNATURE-----

--=-zTC7tvhG9HrXTPzUwtwI--
