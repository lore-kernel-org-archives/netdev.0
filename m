From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] igb: output register's information related to RX/TX
 queue[4-15]
Date: Tue, 14 Feb 2012 22:40:57 -0800
Message-ID: <1329288057.2697.32.camel@jtkirshe-mobl>
References: <4F3B4E78.3060804@jp.fujitsu.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jzfi4wvyHDGZ0BHhZyMc"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:62513 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754752Ab2BOGk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 01:40:58 -0500
In-Reply-To: <4F3B4E78.3060804@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jzfi4wvyHDGZ0BHhZyMc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-02-15 at 15:19 +0900, Koki Sanagi wrote:
> Current igb outputs registers related to TX/RX queues(ex. RDT, RDH,
> TDT, TDH).
> But it thinks the number of RX/TX queues is 4. But 82576 has 16 RX/TX
> queues.
> This patch modifies igb to output the rest of the registers if the
> device is
> 82576.
>=20
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |   38
> +++++++++++++++++++++++++-
>  1 files changed, 37 insertions(+), 1 deletions(-)=20

Thanks Koki, I have added the patch to my queue.

--=-Jzfi4wvyHDGZ0BHhZyMc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPO1N5AAoJEOVv75VaS+3ORXsQAJLtvXS2vczCL7zo82suUKY+
DJ8LJZFdoDJpTHa5wDB+MjFZkluKgiIlnF98UBEnA0OshnkWF+jLKqSUc4aw0Qd3
nIlm5oR/5woK1wyrHS3zZCAJjpgZm83FcDvee/MBO4WQsb2plCQ8ec1xFl5nwsoV
D2lVYFC7RWEtANcQhO9WynR33/5lvF7SGP4hO0lJSxOnQK4xn5BBqas/InxtUWwA
9+p57UAvlEu/IgTdzX2ufu5aFKqviOGnkn9BGtAdhVn4/Im5+9Va0haeKrfif/HH
MC+045EwpDYSMGIBs8APlwlaCGPVKHjLL72g49vX/npwoLfQwuc36pxd09DFfwmC
xRg798iHRiB93fOpzQiB/zNJKAydV7ul8JCHljaJ/6GgfH4JTnnMrL+hpxbYdYu6
ViuUA37FmRXdnkeU82AhYXGGKkVboo1D82lktOupHbXbCXU1c+jKEl8S7Gou1qak
DVbmCNqR7rTwIWumFHPOoBL63CIQLGq0Z1QbiykasHBKiUuXn/0aK+Mc9A2yg+5i
739gG4xxiF/Z5Rini3m4OV5a1Yk/e+x9GENbWezBp86+dkLCFzo4+FKBVD6B49J3
kzy4y2YDFSZ1AR12Y4wWiyXflSMtMgG1Df0XUGwidogqVSpmZ+9zLnDrCnfDiNA+
pFSnlPQvcCBnLrE6zAhL
=gcEL
-----END PGP SIGNATURE-----

--=-Jzfi4wvyHDGZ0BHhZyMc--
