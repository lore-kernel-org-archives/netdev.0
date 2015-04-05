From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH ethtool 1/5] ethtool-copy.h: sync with net
Date: Sun, 05 Apr 2015 02:00:13 +0100
Message-ID: <1428195613.11260.111.camel@decadent.org.uk>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	 <1422193883-30504-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-DVQ9JmfZMd3v5ccFaOEm"
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58642 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbbDEBAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 21:00:42 -0400
In-Reply-To: <1422193883-30504-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-DVQ9JmfZMd3v5ccFaOEm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
> From: Eyal Grossman <eyalgr@mellanox.com>
>=20
> This covers kernel changes up to:
>=20
> commit 892311f66f2411b813ca631009356891a0c2b0a1
> Author: Eyal Perry <eyalpe@mellanox.com>
> Date:   Tue Dec 2 18:12:10 2014 +0200
>=20
> 	ethtool: Support for configurable RSS hash function
>=20
> Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  ethtool-copy.h | 67 +++++++++++++++++++++++++++++++++++++++++++++++++++-=
------
>  1 file changed, 59 insertions(+), 8 deletions(-)
>=20
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 61b78fc..5f66d9c 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -10,8 +10,8 @@
>   * Portions Copyright (C) Sun Microsystems 2008
>   */
> =20
> -#ifndef _LINUX_ETHTOOL_H
> -#define _LINUX_ETHTOOL_H
> +#ifndef _UAPI_LINUX_ETHTOOL_H
> +#define _UAPI_LINUX_ETHTOOL_H
[...]

You've copied from include/uapi/linux/ethtool.h, which is not quite
right.  The include/uapi directory contains definitions shared with
userland, but the headers still need some processing (like removing the
_UAPI prefix from header guards).  You should use 'make headers_install'
to generate the userland version in usr/include/linux/ethtool.h.
Anyway, I've done that myself based on today's net tree.

Ben.

--=20
Ben Hutchings
Quantity is no substitute for quality, but it's the only one we've got.

--=-DVQ9JmfZMd3v5ccFaOEm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSCJMue/yOyVhhEJAQq/MBAAyJ62KY0jKrpCDrK+9yRzClTJEVtyvDhw
CtTCGosF4qaCrG9wDIZ53pq8bhBUAb4SCdHr4ELnR2//dnNz8hPSQA1wL0hV3aSN
swS0ZNVR28GM+Uy1PDqMqnXS4xXNbsPpMlnsmsOLzfCwo5qMVfy9Qzd1l9gMANIi
64lvA6EaMO/xttq6XZGRvtbrlF1VTM5NmxCq3uBoHLNZG1TB1Q66VX7OqDsbDq7Q
xH3fC1fHvr/aZbejtZ+/io5wu1CwS9Um4ERU63apNPOFN1dcG5GX7MPXsxu0XafM
nFBkafezDt1fBHUsPrzFtNgjiyUgLxcxPlfpuo+t7urQYRRASaeD1CNv3Qs6RbXX
vTtVCRQ473nsxcqaJky6vCBGiKF4v9/lXIMcgtW5L1dfYsLfz7Ww0MtQoLto+WNU
eHgUFDm9nh5C6M8AaZVBM2npsqadTYE+/j5jfCBiWSkw2FgVBe/HQJtAJYLOtME3
Mv0NWGxiWsD/63H06bxBvFV4hrbldqUwyNvKF31en6elz4Ou7J+dnQPDMZR6MBTY
GhPCCw1cT0m2uM99GmzCgpuWoXVCIwfmwD1WBOEvjFLi8hTZ2yLbWfjlDiYwZiUn
Ps4MLm/SwF6YTzgUop8Crw6sND9dXoBda6b5yycFI8M+Z+9Fn8rA11DujluVGAx9
Vp5df7Sj3E8=
=Sx3l
-----END PGP SIGNATURE-----

--=-DVQ9JmfZMd3v5ccFaOEm--
