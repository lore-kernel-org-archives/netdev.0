From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 4/4] igb: fix last_rx_timestamp usage
Date: Tue, 01 Apr 2014 18:46:06 -0700
Message-ID: <1396403166.2230.5.camel@jtkirshe-mobl>
References: <1396399939-18420-1-git-send-email-kubakici@wp.pl>
	 <1396399939-18420-5-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-39G9E5rS92KRLWRyGu9y"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Matthew Vick <matthew.vick@intel.com>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35735 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754466AbaDBBqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 21:46:13 -0400
In-Reply-To: <1396399939-18420-5-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-39G9E5rS92KRLWRyGu9y
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-04-02 at 02:52 +0200, Jakub Kicinski wrote:
> last_rx_timestamp should be updated only when rx time stamp is
> read. Also it's only used with NICs that have per-interface time
> stamping resources so it can be moved to adapter structure and
> set in igb_ptp_rx_rgtstamp().
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
> NOTE: Compile tested only!
> ---
>  drivers/net/ethernet/intel/igb/igb.h      | 16 +---------------
>  drivers/net/ethernet/intel/igb/igb_main.c |  4 +++-
>  drivers/net/ethernet/intel/igb/igb_ptp.c  | 14 +++++++-------
>  3 files changed, 11 insertions(+), 23 deletions(-)

Added to my queue, thanks!

--=-39G9E5rS92KRLWRyGu9y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTO2veAAoJEOVv75VaS+3OZDoQAKJJjGZHuEaNK9rOY2G0Jw64
hw+4ZplJAlipnUQ8ScjusdqjV4hb09SEjHhOk2GvL6y23iHq8zARdQwt+yof2dYs
PxGfRO6N3hc/ltNk4JnJeoKvmWApFIsyATBWnk2XrhLwd0FM1FE2CraEtYM+Q5UM
B0CvZrv+mSDRPdzS2M8DC4K+gnKe3DS0TRQY5Yns1XAibdjf0zCeT0OPDeHwiNTB
ZcUAHZfjSI7Mf/55rYQYtVQ3TjBxPhTphow3IRVYpwufpCHTcfsUV1FuFtCHK1cR
JlljjOo/E23KagV4xyjmq2EGMXIIHugIlFH1mFdRThK+pxoPnSWIxzFn8xRZxx48
/vVimlvud9vTOsuhUQyR2I3MFJFuLbYsmoZBkn90E1G4Rtji1qo5qeDoHGhSxWYp
sHV0y3/d3OZz0eu8fpm19oa2XLxDKfRePGi24fIebMUF18Nv1/ByHgS+XihZr6Rl
eK7BvoZ/HyL+3gaaJkMZOfJlFAZagsV5iZv6XZtUoaE9MBV6rDJNww79cG1jW3Z6
C2iSV/Y42mPnFYi/JNpBDJpLb3OhlevTzW3sXxUQOXEqIqyo5rVqoiXgJqHg0qEx
owzofmB0NAX7HZeU+dvtC3rA27RkOtbs4qyDx63BEYKNLYMLVjRmm1ppPHtczmwq
PMrGClHggdBomEUMzXI1
=GBZW
-----END PGP SIGNATURE-----

--=-39G9E5rS92KRLWRyGu9y--
