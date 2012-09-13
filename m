From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Thu, 13 Sep 2012 14:05:59 -0700
Message-ID: <1347570359.2219.96.camel@jtkirshe-mobl>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-QNSvpaaFnrreAPBHHDh7"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:56787 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758830Ab2IMVGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 17:06:01 -0400
In-Reply-To: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-QNSvpaaFnrreAPBHHDh7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-09-05 at 16:35 -0700, Kirsher, Jeffrey T wrote:
> This series contains updates to igb (specifically PTP code).
>=20
> The following are changes since commit f6fe569fe056388166575af1cfaed0bcbc=
688305:
>   Revert "usbnet: drop unneeded check for NULL"
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>=20
> Matthew Vick (6):
>   igb: Tidy up wrapping for CONFIG_IGB_PTP.
>   igb: Update PTP function names/variables and locations.
>   igb: Correct PTP support query from ethtool.
>   igb: Store the MAC address in the name in the PTP struct.
>   igb: Prevent dropped Tx timestamps via work items and interrupts.
>   igb: Add 1588 support to I210/I211.
>=20
>  drivers/net/ethernet/intel/igb/e1000_defines.h |   8 +
>  drivers/net/ethernet/intel/igb/e1000_regs.h    |   2 +
>  drivers/net/ethernet/intel/igb/igb.h           |  29 +-
>  drivers/net/ethernet/intel/igb/igb_ethtool.c   |  84 +--
>  drivers/net/ethernet/intel/igb/igb_main.c      | 329 +++---------
>  drivers/net/ethernet/intel/igb/igb_ptp.c       | 676 +++++++++++++++++++=
+-----
>  6 files changed, 708 insertions(+), 420 deletions(-)
>=20
> --

Dave-
I see you have set this series to "Changes Requested" in patchworks, and
I am assuming that is from the discussion that occurred on patch 04 of
the series.  That discussion came to the conclusion that changes should
happen in the PTP core, and that the patch is fine as is currently.

If there was something else you want changed, let me/Matthew know so
that we can make the necessary changes.

Cheers,
Jeff

--=-QNSvpaaFnrreAPBHHDh7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQUkq3AAoJEOVv75VaS+3O9esP/2wU+9g2JQArGRC5mbjdBDeM
NlViwyCkrIVX+qQXzs6QUzrIOAqr7HAT7j5wHKFRT4BPQlUHHePZWsLEdtHHwzHY
g4I32I97n+ie5SMGhAb1xeNVijLKx3k+VaOpee+S0CwzpveiOss2Plf5HQpP6JZi
TeeGjRglluXtoyUXmhdcsKEN81mDlKURqtJD8/AefXQz2He2cCd8X0oMh1g5Jm5i
3Dl4Q1QGoWBELAqzoaEcFmXHFaP5nRhvHttQORPodfWv76kgZg5RcsMeQPG9wNWI
wASkK0r0Bw7Zfi1ykBCxvjc2um9GJmbyTnO9oDuevOgGaT5epbmB1gr9qob3nwIB
Awl3aQlzIV5ITzBfg3jwdnVZ3gS/7ayNEBG9Dzx/UB9bk+PlHj8/6/2RE6gaYli7
/gtaO8T00Xu/RX1D7Qs3iKJFwWVeQy4UjE/ROtKZ/OQga3488PPUm/ZcFnHLDY7S
9vSXyC1bdS47VfMp8RnT7YlqY7bwdA9H4GsY5XLs9eGeocIRJROauD7HCaZpA7gk
fFT8/DCWrIhGqsndCQsWKl1iqNxFqe0nrfkeC4PfceZwsd0VsDxpx6sTpeytS0KV
uM0ryyQr4ozlqN9DUJgit/NFOblpSBIWylLie7bBNr9f/X8nUasrnqC2tofzcs0t
+8FlK8Ljyyd0LObv8VHA
=3m8w
-----END PGP SIGNATURE-----

--=-QNSvpaaFnrreAPBHHDh7--
