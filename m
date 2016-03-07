From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 08/12] ethtool-copy.h: sync with net-next
Date: Mon, 07 Mar 2016 16:10:13 +0000
Message-ID: <1457367013.15205.26.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-9-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-4hvh0V9Ta9Djd72AUtc1"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43717 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752924AbcCGQKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:10:20 -0500
In-Reply-To: <1457138533-2417-9-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4hvh0V9Ta9Djd72AUtc1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: David Decotigny <decot@googlers.com>
>=20
> This cover changes up to:
>=20
> =C2=A0 commit 3f1ac7a700d039c61d8d8b99f28d605d489a60cf
> =C2=A0 Author: David Decotigny <decot@googlers.com>
> =C2=A0 Date:=C2=A0=C2=A0=C2=A0Wed Feb 24 10:57:59 2016 -0800
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0net: ethtool: add new ETHTOOL_xLINKSE=
TTINGS API
>=20
>=20
> Signed-off-by: David Decotigny <decot@googlers.com>
> ---
> =C2=A0ethtool-copy.h | 485 ++++++++++++++++++++++++++++++++++++++++++++++=
+----------
> =C2=A01 file changed, 405 insertions(+), 80 deletions(-)
>=20
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index d23ffc4..37fd6dc 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -10,8 +10,8 @@
> =C2=A0 * Portions Copyright (C) Sun Microsystems 2008
> =C2=A0 */
> =C2=A0
> -#ifndef _LINUX_ETHTOOL_H
> -#define _LINUX_ETHTOOL_H
> +#ifndef _UAPI_LINUX_ETHTOOL_H
> +#define _UAPI_LINUX_ETHTOOL_H

You've copied this directly from the source tree. =C2=A0 Instead you must
use 'make headers_install' to generate the UAPI version (under
usr/include/).

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-4hvh0V9Ta9Djd72AUtc1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3aflAAoJEOe/yOyVhhEJomUP/3KbmKvMuebUF+2Gs9Kj+xEJ
MbdijJzHc8hwCRU3rjR4Y0fO/Emdio7YfT+/QLp/QEEHgptnjGtWkDCOOFs8kiTK
jUTyfb/tXaQ3ctIt/tiF07YA50xgjyEafnI6jrlRr9XSHMUCGvp9Mac+pP6SB03d
KxAsJmXxRuPIURUAnGVP2X35fWcJ0tPIJ1SfvmoEkYI+27kDHg0+vYRw0TOO71Fb
5zqm5+we+rToppjJgPeVC7FrL/Zci8YO56NphPTC2AWd5YrrmLiZBTd0Q9TnMd9P
ogfi8/cTorJFU+OCGqbDztkBuiVVtmkmW1wT1ai6ICZrskmWPtQeb/hNtbI8djd9
cpB0am/miUGAq3aSLVzIT8eNjrD3gN+rlW0av96mMC54eVVyt5NHMPKLN4p38IWM
dESJoLvyOTqnztNH0b3X+zdMoxU9RKb4iGpwvHIV4OkLIzf9CVCIz+ADQxsThN7b
nsjMlJi+bZ3UhBNfSNf+dOhdl18FwdkhlnKMf8+wJtJb7rINUzvj4kSs110v3VCT
oGQkiIhSMjir0gWAdkUkhy14LeyY/y20WkEjpBvgcv3wdOafjW1kVDg5CtEHBJF3
HfLEMB4bzeFGORU4tF1BjeDDX7dyiChlcBBTpwRv5MB/EhgjWZt96wrIKaGvoEUO
gLVwC4nzB6S7ojPmmiVb
=tz7r
-----END PGP SIGNATURE-----

--=-4hvh0V9Ta9Djd72AUtc1--
