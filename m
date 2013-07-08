From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] drivers/net: igb: release rtnl_lock on error path
Date: Mon, 08 Jul 2013 12:37:23 -0700
Message-ID: <1373312243.2158.0.camel@jtkirshe-mobl>
References: <20130708072257.20564.36904.stgit@zurg>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DRT85W33bsMkqQ5EoSC4"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42336 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab3GHThr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jul 2013 15:37:47 -0400
In-Reply-To: <20130708072257.20564.36904.stgit@zurg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DRT85W33bsMkqQ5EoSC4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-07-08 at 11:22 +0400, Konstantin Khlebnikov wrote:
> This adds missing rtnl_unlock()
>=20
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c |    1 +
>  1 file changed, 1 insertion(+)=20

I thought I already had this in my queue, if not I will add it.  Thanks
Konstantin.

--=-DRT85W33bsMkqQ5EoSC4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJR2xTzAAoJEOVv75VaS+3O1V0P/jWqgbEIQP11W21xGITic2hb
nr4eEjoWrVi0h4evFrgo01FneN25K7WX8+NNYH9oJhi6HHdtyiTvVaahS/jYw73+
XFmJyVj3e4D8/qjXHltRngVd26x+gG3PBpIQM+I7DFyu7VpDo/d5N7RjehPkmhRK
yylGGr44zEvU5pqRkQqC66lX64Lx19gBDZIKJqOow2e/N/X4mwSP/PiroDThVtpS
UGWnElfq8UWifr3Y23VdPwafGT6B9m8RbCZuNFBJzEcR4ggG2u+DkqPmTgugaffS
XeU02Huu8Bze0536apdJdU3zp593aQ+kOC1+wP+p/Kd8lKY3Z+O0sohhQuvIXST1
acux2kYl2B4/TmdyEdMnrkFHaUQXsU1xW35oFBxwv+Lav68p6xUvt8We5z5xmmXo
lzQYm+votd4m14BciOvyLk5NtPY0iV4Czv6mfyORJE5LzopGHRZCD0pJxyo/KQfj
824RUHKMEzoRnwYJZ71MSISss8IkMWRBIj1eHurbEvHwVxjJlmBzFyeVAnm8ElQt
4dEX++1phUmTqOBvUe1G98+VlAvwulqx/Jex4QQNZQbyBHJJQDRvF8qHOxHwmnvV
NIfILC8Y67HhrP5oSgYyATjApRap0l1PVX5jZm7yfYa1PCJwNfjuHysyjCHZgO05
4lxCaNiSKHDN5FAvvluF
=rXcp
-----END PGP SIGNATURE-----

--=-DRT85W33bsMkqQ5EoSC4--
