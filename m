From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 3/4] igb: do not clobber the TSAUXC bits on
 reset.
Date: Mon, 27 May 2013 17:44:49 -0700
Message-ID: <1369701889.2116.137.camel@jtkirshe-mobl>
References: <cover.1369645944.git.richardcochran@gmail.com>
	 <0c838f7cd866c88eb85bb8d2aaaef21048a7d0e9.1369645944.git.richardcochran@gmail.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HByPbCK17YyqABamv2+1"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12897 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab3E1Aov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 20:44:51 -0400
In-Reply-To: <0c838f7cd866c88eb85bb8d2aaaef21048a7d0e9.1369645944.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-HByPbCK17YyqABamv2+1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-05-27 at 11:21 +0200, Richard Cochran wrote:
> The TSAUXC register has a number of different bits, one of which
> disables
> the main clock function. Previously, the clock was re-enabled by
> clearing
> the entire register. This patch changes the code to preserve the
> values
> of the other bits in that register.
>=20
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ptp.c |    8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)=20

Thanks Richard, I will add this to my queue.

--=-HByPbCK17YyqABamv2+1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRo/4BAAoJEOVv75VaS+3OlRkQAKOI5xjsVIfw9SRsueHkfK0s
k2VKp3T7Ah3ht5MY9AcvG/aNNMPNgOfGZh2dtEbDKLYj149MqGj/GoNPW441vVpD
euO3ClQ/5tkkaAlcLrAodH5jhRKgVtFY8FR2nu+qTMPNYyxFPSVNNob1y+aUOOTm
029BpXWeVqN/32OComAhlogYdhc5ssSUJ0CmLHcTQ3F/ewmiy0E4fSz16jTe8RNU
zTl8QEN+itOhBZbupf2jzlgWGIyDIVrVDtybI4m0sDN5ExtoLpT3or1vD7DHjJE8
j2kwhBip060spROaAY8w9e58miasVBvMvSCyYc9cTt8V87DD1WZCjhDl+y19RlbC
R6d8ig9DPqPU/Z3NU1oG3h7JRAUFPqGX7pM6sIHPFBJw19wKSQvBpK6jez8xjWFl
IQWnX14XrlHAhCCNqxlAqq8SuxRA6NaX2BLJtLsVyGyLG7yYQ7/4WVFibDB9syfH
8buxVgVcecLipUnSFkbFnQ6Y9Z11RF7da0QfrdS7SX/nLXnIPv/ZTcm95puNTR10
/kncgaVkEHnY3JbbgKPQmlrS+mtjIyS4k/GhKXz4gknTIb/vLyoxsR7XlgwfPzxE
GaGEIyhp9FRu3mYT2tGcwsxPTIsSWNromfpnJKnULpk38uWwb0kCvMHg3rsvSl5+
1k170CmNoqbfxThLXR/d
=FsdP
-----END PGP SIGNATURE-----

--=-HByPbCK17YyqABamv2+1--
