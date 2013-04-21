From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: limit udelay for phy changes to 10000us
Date: Sat, 20 Apr 2013 20:34:45 -0700
Message-ID: <1366515285.2209.17.camel@jtkirshe-mobl>
References: <1366515095-17734-1-git-send-email-andi@firstfloor.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-wISqptdlIeOmepmk70ZO"
Cc: netdev@vger.kernel.org, Andi Kleen <ak@linux.intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7082 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605Ab3DUDer (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Apr 2013 23:34:47 -0400
In-Reply-To: <1366515095-17734-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-wISqptdlIeOmepmk70ZO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2013-04-20 at 20:31 -0700, Andi Kleen wrote:
> From: Andi Kleen <ak@linux.intel.com>
>=20
> If you really want 100000us you should really use mdelay or so.
>=20
> Found by the LTO kernel build
>=20
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  drivers/net/ethernet/intel/igb/e1000_phy.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)=20

Thanks Andi, I will add the patch to my igb queue.  Do you want me to
fix up the patch title as well? :-) (s/e1000/igb/)

--=-wISqptdlIeOmepmk70ZO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAABCgAGBQJRc15VAAoJEOVv75VaS+3Oz5IP+gNsXMKZLJtlK449UnnsmeDu
RVXoHUKESiIoEVuD2688J1PPQxmccpizZAtc+zbgItFeXAo4+v4cXV9+pEc4+qlF
Ob0W/Hz+96FoconGrrYf9lYmoQYKzZttPlfAhvtrq4pCTpF8/M66wydTwqEgeSCy
ap6Zy3TSx4lwwlTLNzZMxfATEgrkXbYkj28V37x/JjN7CATdp+bvO5yRFzSY35gy
8Geh2gJqbsrSwKH2UGI0HN1fp7R3H3LctMaD5uzoZQgUMeaj2KM1FxEd1qYzcHwo
iyI8sesIZBdtwmhJEPBr9/X2hTo/zj6XmF+kgNVbr596pTbi0RTBQTMBE3oKa0Bo
2AiVa+ly5B66XbWR3FNoGYxEbzDaMCnXrARq7hBsk8dx2wFjAu7PY9/4lF4l4WQU
exs83EzCtLLi/mmSDultFh5lZ2UG6QesG/sQGTXdqHrtyQwN+Cb9K/wKExUeQMQX
/sZE9bZanOIIZ6V1MKHXznQN3hW6lMsh1NBf/iYkRFJjlYJvbfyGI9x3n17GFrDP
Tu5tB+3VIT5dyQMAYahTq9V9kGmekqw+sTLTbuUbS7LFNXLpmOVsejaCVCo+Zv+8
wLoYvnjzCGmlusXV5gcsCgqNORReeQwIw4XBxrp2WvamFYs9VFCFq0WSYMPjWrNC
heiguaSTt2chAFVG5hHQ
=3j/Q
-----END PGP SIGNATURE-----

--=-wISqptdlIeOmepmk70ZO--
