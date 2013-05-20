From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH 2/4] e1000e: Use marco instead of digit for defining e1000_rx_desc_packet_split
Date: Mon, 20 May 2013 02:37:29 -0700
Message-ID: <5199EED9.4040401@gmail.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com> <1369037707-27026-3-git-send-email-weiyang@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig7B4C72C281A0DEFAEC4E1967"
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7085 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097Ab3ETJhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 May 2013 05:37:31 -0400
In-Reply-To: <1369037707-27026-3-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7B4C72C281A0DEFAEC4E1967
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/20/2013 01:15 AM, Wei Yang wrote:
> In structure e1000_rx_desc_packet_split, the size of wb.upper.length is=

> defined by a digit. This may introduce some problem when the lenght is
> changed.
>
> This patch use the marco PS_PAGE_BUFFERS for the definition. And move t=
he
> definition to hw.h.
>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/intel/e1000e/e1000.h |    3 ---
>  drivers/net/ethernet/intel/e1000e/hw.h    |    5 ++++-
>  2 files changed, 4 insertions(+), 4 deletions(-)
Thanks, I have added the patch to my queue for e1000e.


--------------enig7B4C72C281A0DEFAEC4E1967
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBCgAGBQJRme7aAAoJEOVv75VaS+3OtCwP/iKOhD/I50mkQpqZFBeQL4FX
yqNfYvVHX6n33EFlgpjBmBKI+GUkPlAr1qZ8GQyqpcvk127i63HJA2F+8x5octow
N9VaaHRUI6Jvvzn1sOatMs4QJHjaBKISQaUwexNLwFA9H7j5k7iVFJI+Jt4CCYrL
XENXifQ+eFuIG+UEqVkUYiu2K3/2y3IS5REUYbUnyEI/51IUaonnbGSQQet5k4bd
2uwc4qmoRqMu3XXkq+bsdCYcdboeuGvyxSKlOUgezP/voeVbDm1H9RK6Dp+kv71K
JkeH9CCBLV83ww8gRV6tPQekubo6rssDpXjS5fwh57+R50Pr8JG2ZVqOPgzCybkD
l98vOPP/q5hEZAElu821MWysY7Gy7QHQ5I+j9S94mjIV88zX2EeIq03UGch3+QWg
7942q6/8aF8SjcPOsovJgqtY7SkhvRYIKCio50+pevz0cLXxEw51XdjBPENlAo7a
AJTPhSJ2vL54Xfzl/N83yEBlSSpB+EOw2bwHU6A8inewFHk9l31pGRTDPKcHNjJr
FOr+2EgRcWIXWfSMDpSqXDLh5lkVTG5LAOKKAxgzLyrHCrR3Rz9PxAY6C3nlegZL
6k6JzcuvaxiZtEqmswyVwXMgETKxFk5VxsR7Y3seAaHrOtDX051764SAJVe5N6RG
XGVPPYNV+J1K+wgVWO2u
=UrNz
-----END PGP SIGNATURE-----

--------------enig7B4C72C281A0DEFAEC4E1967--
