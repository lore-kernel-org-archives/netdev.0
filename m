From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next V2 0/2] igb: ptp hardware clock
Date: Tue, 27 Dec 2011 09:28:33 -0800
Message-ID: <1325006913.2750.43.camel@jtkirshe-mobl>
References: <cover.1324901880.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aSffa+tGMzNqGWy8y89Z"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44650 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754464Ab1L0R2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Dec 2011 12:28:34 -0500
In-Reply-To: <cover.1324901880.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aSffa+tGMzNqGWy8y89Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2011-12-26 at 13:26 +0100, Richard Cochran wrote:
> * ChangeLog V2
>    - Fixed wrong bit shifting in the 82576 code.
>    - Explained the timestamp locking with a comment in the code.
>    - Preserved the comments from the original timecompare implementation.
>    - Added an additional test within the overflow counter code to fix
>      a race condition. Details of the problem are given in the commit
>      message.
>=20
> This patch series implements a PHC driver for the Intel 82576 and
> 82580 devices, as part of the igb driver.
>=20
> The first patch adds the PHC driver code as a new source module but
> does not link it into the main igb driver. Because the system time
> counter is not so very wide, the code implements an overflow counter
> in software. Every read operation maintains the overflow counter, as
> does a "delayed work" watchdog. Only the base clock operations are
> implemented. The hardware does have some ancillary features, but these
> can be easily added later.
>=20
> The second patch removes the timecompare code and links in the new
> functions.
>=20
> I have tested the 82580 with good results. However, I don't have the
> 82576 and so would appreciate testing and feedback.
>=20
> Thanks,
> Richard
>=20
>=20
> Richard Cochran (2):
>   igb: add PTP Hardware Clock code
>   igb: offer a PTP Hardware Clock instead of the timecompare method
>=20
>  drivers/net/ethernet/intel/igb/Makefile   |    2 +-
>  drivers/net/ethernet/intel/igb/igb.h      |   21 +-
>  drivers/net/ethernet/intel/igb/igb_main.c |  167 +----------
>  drivers/net/ethernet/intel/igb/igb_ptp.c  |  486 +++++++++++++++++++++++=
++++++
>  4 files changed, 505 insertions(+), 171 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/igb/igb_ptp.c
>=20

Thanks Richard, I have added this series to my queue.

--=-aSffa+tGMzNqGWy8y89Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO+gBBAAoJEOVv75VaS+3OcGUP/0W+ag1X+K8s1IZrX2AGx6IU
FL6JCq/hz+dHK7LNZBm8ZttFb9UOkf2FB3s01WD2X7fEJBwBSLk0FKNI6VwQtO9x
QAfryHNM7+6b1YQeaj/mmU17LP9ZvtgTJeQlqYeyl7hBaOt28oJvdoVMZ3uA/4l+
T8yNoLlL4n0msrHiam5a8O1xduPr7gwsMk01ZpPCJYg35xNukJtPmGut7LvrSs13
8H0t59qsEP9r5/IFr9dA1dp9B1mh6lnc4e7Ekr19mSChbrmqbEi72eApJ0R1KJXy
AgEhIVqf1o1CmkrXcjIobvNL85qFEJoK77/B1obVNGDg+CjO8HZGynIDpVNr/VjU
HpTKZnCeV38AShZr4wBeAW2AK2Md0HcTz5RBgpW7ewi2ESXEilgfhT7EKtV61C00
+n/CFZ6EpkZvsUDORM7YJwLsf20SpRzX38NL6j0RP0UragrX4Sxjy4RD/Nu0tVov
hNoE1g67TMATCJP1Ubrn739zgDUm7Eyt9JuiIZIBQPh5OAHvH1tCNA3yW5yuXsYD
niSrgp/ydJcmdjtxosm7CpRt4bxm47jjGy2eHWxcFYedGlwmMZGwRFye6RBqNx8m
m2JDWTBLXHr4W0qqUJPAQC4AWdLTEP1HzhgB5ajV3aWHyWUk6xqTVhzF6RSf/ehG
QVXzB2aq9bFNkbOFU41p
=hFiI
-----END PGP SIGNATURE-----

--=-aSffa+tGMzNqGWy8y89Z--
