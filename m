From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCHv2] Fix e1000e with Intel 82572EI that has no hardware
 timestamp support
Date: Wed, 06 Aug 2014 23:34:12 -0700
Message-ID: <1407393252.2244.1.camel@jtkirshe-mobl>
References: <fae55865c8fb40f8b2f05b56b070433c@FE-MBX1012.de.bosch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gpz4Z+F9QUGI9y3GMYk3"
Cc: Richard Cochran <richardcochran@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Koehrer Mathias (ETAS/ESW5)" <mathias.koehrer@etas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:56748 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754411AbaHGGeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2014 02:34:16 -0400
In-Reply-To: <fae55865c8fb40f8b2f05b56b070433c@FE-MBX1012.de.bosch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gpz4Z+F9QUGI9y3GMYk3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-08-07 at 06:29 +0000, Koehrer Mathias (ETAS/ESW5) wrote:
> With the Intel 82527EI (driver: e1000e) there is an issue when running
> the ptpd2 program, that leads to a kernel oops.  The reason is here
> that
> in e1000_xmit_frame() a work queue will be scheduled that has not been
> initialized in this case.  The work queue "tx_hwstamp_work" will only
> be
> initialized if adapter->flags & FLAG_HAS_HW_TIMESTAMP set.  This check
> is missing in e1000_xmit_frame().
>=20
> The following patch adds the missing check.
>=20
> Signed-off-by: Mathias Koehrer <mathias.koehrer@etas.com>
>=20
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

Thanks Mathias, I have added your patch to my queue for Dave's net tree.

--=-gpz4Z+F9QUGI9y3GMYk3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJT4x3kAAoJEOVv75VaS+3O8XgP/jFoNR5BEKxIhFJdhLbcwWnh
d4fEqXJa9FurUz+m+ipeBQQ34n7VTwDmOhD/hlO3pbjl7iLOrXrNJNkTbVRIZf47
0A6uvXFij1N8egidPGrQI96svcydhE4/cHGzJDLFG9mVlS2mDaZ9jfQ4RyTRf6ym
PA6aNowNmToRl4heWosWVh045vmSSvpZ/t7h7nHuFsvJ0yNWBQzUtZQeKko0gYy6
bGTqucVdM9U/Htril8HT3UhPiG8qKaHf7B7Rn3Sb3n0C/pMIucQryMkU6UQVMJa0
FZ0CRJuvIZ5yQfgJ0gExTt2ZNJXFKotzjFnTnH4lWcX78OmN7iybLsLcmfYa1Mk/
ym2g2Kkl9mHNwyWczhpd2GFrAzEN+UqKLTQE2Jd/X95bSM/o4xKegoLACGnIrvc7
rz0KeGWI0vWm1Km7+kPJk95a9yJqEUrRhR9rClVW40AqTqNVwwXXee59U/B/nOda
M0NnfG1MZKgJXW1EHYosz09Z2WpJBBVWsDpu8TwWskQoUt905248G4i0kfcsmdrh
NTb8EkxjQ1atn1LHWCEnTSLIoK68/ONgNdw9AN9Yzfx4/Iz5afZZDHQKdDEV8tXZ
a3j+OGOXLQkHxI3lJc6b9d83Ie1fqhlEwoulhNQrW9pReN1N+MXPjooQ3/2CwdLm
ii102+0JGtsgz7AjL6ki
=Juuk
-----END PGP SIGNATURE-----

--=-gpz4Z+F9QUGI9y3GMYk3--
