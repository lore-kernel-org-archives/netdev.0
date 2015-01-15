From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] e1000e: Fix 82574/82583 TimeSync errata
 handling for SYSTIM read
Date: Wed, 14 Jan 2015 16:36:00 -0800
Message-ID: <1421282160.2309.25.camel@jtkirshe-mobl.jf.intel.com>
References: <1421278252-13622-1-git-send-email-bhavesh@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ras0tbXAuWy+Kgve5eyy"
Cc: linux.nics@intel.com, netdev@vger.kernel.org,
	pv-drivers@vmware.com, nithin@vmware.com, ninad@vmware.com,
	smurali@vmware.com, gyang@vmware.com
To: Bhavesh Davda <bhavesh@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46868 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549AbbAOAgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2015 19:36:01 -0500
In-Reply-To: <1421278252-13622-1-git-send-email-bhavesh@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ras0tbXAuWy+Kgve5eyy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-14 at 15:30 -0800, Bhavesh Davda wrote:
> In emulated 82574 vNICs, TIMINCA might read as '0', so this change
> prevents a
> divide-by-zero error.
>=20
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> Acked-by: Nithin Raju <nithin@vmware.com>
> Acked-by: Ninad Ghodke <ninad@vmware.com>
> Reviewed-by: Guolin Yang <gyang@vmware.com>
> Reviewed-by: Srividya Murali <smurali@vmware.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 3 +++
>  1 file changed, 3 insertions(+)

Thanks Bhavesh, I will add your patch to my queue.

--=-ras0tbXAuWy+Kgve5eyy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUtwtwAAoJEOVv75VaS+3ObxQQAJig0ynOxHu1MjP+1+MZJxan
Qk3D3RAHflIio7Cuxr+R+ponJAq93fMqPjHiKZtPbIQtn7J8c6mhkWL10/vnpMpl
8A1t2aFq917iq11yjXpbzXgrfTb8Tmlb+b0P7YJD5ZY4rLkOY+JmNPatcnpp+jb8
yttuaj/Sg9jq4Y8O8TCluSdhMuvQqEYnITKMg364LPKe3JWhy3uJijPR30yySOLA
VuwleX2ZLaimdWqnJYzCvYanSe2cPxlcI36VNCGsYedewUuSOamZ9p90uRxUqrAO
oGwawZoizuFwjihOOe5cAnBIBoZcJMFb42hEcL6Ml4ymjzr+6qxTnGPS93v7/RCK
AB1XierNDHAI2tAs61R3gyUjCZag/s4IV4IDV+ZjEYw2niILlpIB5gSxYJRE5yNP
vS7YXS7AqkNpajWNL7mf/Pm9COhexOu03P2sKd8QxLTRibyPWspOrZ+xHqVdQcLd
2jGRo7A0KOf8e5YkUYTrg/l9JBRfVQrw5ec/rs/+PaHl5juPRqSPmsDRz+ZasZpt
zaguIw/5SRzfeBLlsej93DLYxyFcaBQgBpood83sEbj2ZA7HIimeA3cNQoAkGH/P
eikMbb6vCXaO3drH3i2A+ry01TD31a07m9dTFnwVpFnJlP89ti9eB+t78nOyV/SO
AYcjrzaB6oJcDRZScEHv
=RQF5
-----END PGP SIGNATURE-----

--=-ras0tbXAuWy+Kgve5eyy--
