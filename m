From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgbe: stop PTP before suspending
Date: Thu, 20 Mar 2014 18:36:37 -0700
Message-ID: <1395365797.2050.48.camel@jtkirshe-mobl>
References: <1395342872-13496-1-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Nqkkkpp60DYIhXgcBmvp"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55179 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760401AbaCUBgi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 21:36:38 -0400
In-Reply-To: <1395342872-13496-1-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Nqkkkpp60DYIhXgcBmvp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-03-20 at 20:14 +0100, Jakub Kicinski wrote:
> Resume path calls .open but suspend path cannot call .stop because
> fdirs should not be freed and control over hardware should not be
> released until WoL is configured.  To avoid having to duplicate all
> changes made in .stop on suspend path split out part of .stop that
> is relevant during suspend and call it from .stop and during suspend.
>=20
> This fixes ixgbe_ptp_stop() not being called on suspend and helps
> to avoid similar bugs in the future.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 27
> ++++++++++++++-------------
>  1 file changed, 14 insertions(+), 13 deletions(-)

Thanks Jakub, I will add this to my queue.

--=-Nqkkkpp60DYIhXgcBmvp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTK5elAAoJEOVv75VaS+3Om2MP/387nGR7OEfLgRMIxNVjZ+AN
NN9UAfctQxUYJp4/rrD9D8b/E5lr6Pf3kSUsInkPwgDvAxNrzbbvONssfk2D6fVp
uu3IOw/fScg0t+jkl79R+Xm/HwaURGO4f9QEpaIq0pLP8TNw/tF/fu7SrHPNUID+
J+XN0g/U1hvsVJJfEAZ+NdFchN9HYCgJ1T0vzt9CPhSvLaoF0YWSXX9Kt8HE5LG6
9/spulPywiKqzrchVHfVMR+87PpbTcX4UzDa43IYA8bfJfopX5LWE2xMFybflUrZ
DUOB3vmrpbaPvB3AwCoikPEqoEUtId7+cj6y0CT2iM24Yxfgx4qLalH1s69vAot/
RryOpxVFxzVSoVzAWg8teeBTpg5B2uQeHmMuoCHRwJEdWrF9q5X0Awl8TNpZ27ai
GcsE8a+7IvPzQa6xXWln0K3wcMMAlPPjctn4KqiwmQHAMmuKDcw4iLro1Vxmxy+5
rd4pqsq3dMLvv/cXqZ63d1NUMFtZ7ZzP36oIM1z0bLV3SVjTTwHdtNpyzxtTb+28
CtC6R/93wrtIzv5vrS0se6SzJebbMAyFRz+0ukWjY2M66KiQt4dnsqjq/ZnylbHM
LQRo63xHVyX0fdwuSUXmfUIHn8zvVDT+AzLonpWD8IgO56qizEQDr79CucAdWIZU
vBIFcIQYuk3DaLn1oC+m
=EUjM
-----END PGP SIGNATURE-----

--=-Nqkkkpp60DYIhXgcBmvp--
