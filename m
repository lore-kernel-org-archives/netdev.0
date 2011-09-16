From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] ixgb: relax stack usage of 768 Byte
Date: Fri, 16 Sep 2011 16:08:40 -0700
Message-ID: <1316214520.3661.87.camel@jtkirshe-mobl>
References: <1316208897-4557-1-git-send-email-hagen@jauu.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-s3qhlkKJYPwhLOzzU5Cn"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:15568 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754123Ab1IPXJG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Sep 2011 19:09:06 -0400
In-Reply-To: <1316208897-4557-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-s3qhlkKJYPwhLOzzU5Cn
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-09-16 at 14:34 -0700, Hagen Paul Pfeifer wrote:
> ixgb_set_multi() will push (128 * 6) byte on the stack to set the
> multicast filter. Fix this by allocate the scratch buffer on the heap.
>=20
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgb/ixgb_main.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)=20

Thanks Hagen! I have added the patch to my queue of ixgbe patches.

--=-s3qhlkKJYPwhLOzzU5Cn
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOc9b4AAoJECTsCADr/EWU5CkIAKj6M8TcVm7Sszs5SoroQky9
Pxpg5PNI4sr6FptPrYxD97PeqOHbv3JU2XQPGr7/iWRJjEXG5rRsJYkhdIrBZXDp
wSqhWhQ/a61GGbEeO6D0EWhcKJvcdNb8iLw6lUbcbOeecX3WvYqyiDgA87sgOP0u
DpFr/wZHt/3qsY4NhlmnaDDxtluYZxafWSdxv0YecB6IQO+k272gAa0lW356zOPP
c9pcL8fEUoDM7CHmVSwNF5xolUWXM/62DWdHlBoC5gYGkmPw/D8sHu5/MGKi06K2
8i7hg9Ell6KFC0yQ/A3IqRiaeBLZoeKIt5+4aY1Z6V8vxF9uk/7aIKUUDKSnCmM=
=UxRA
-----END PGP SIGNATURE-----

--=-s3qhlkKJYPwhLOzzU5Cn--
