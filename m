From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool][PATCH] Fix build with musl by using more common
 typedefs
Date: Sun, 14 Dec 2014 18:37:24 +0000
Message-ID: <1418582244.30883.0.camel@decadent.org.uk>
References: <1414323849-5739-1-git-send-email-paul@paulbarker.me.uk>
	 <1414323849-5739-2-git-send-email-paul@paulbarker.me.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-l4ah/L0g1n44VlUvfGB2"
Cc: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org,
	John Spencer <maillist-linux@barfooze.de>
To: Paul Barker <paul@paulbarker.me.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33796 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750708AbaLNShv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 13:37:51 -0500
In-Reply-To: <1414323849-5739-2-git-send-email-paul@paulbarker.me.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-l4ah/L0g1n44VlUvfGB2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-10-26 at 11:44 +0000, Paul Barker wrote:
> When using musl as the standard C library, type names such as '__int32_t'=
 are
> not defined. Instead we must use the more commonly defined type names suc=
h as
> 'int32_t', which are defined in <stdint.h>.
>=20
> Signed-off-by: John Spencer <maillist-linux@barfooze.de>
> Signed-off-by: Paul Barker <paul@paulbarker.me.uk>

Applied, thanks.

Ben.

> ---
>  internal.h | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
>=20
> diff --git a/internal.h b/internal.h
> index a9dfae0..262a39f 100644
> --- a/internal.h
> +++ b/internal.h
> @@ -7,6 +7,7 @@
>  #include "ethtool-config.h"
>  #endif
>  #include <stdio.h>
> +#include <stdint.h>
>  #include <stdlib.h>
>  #include <string.h>
>  #include <sys/types.h>
> @@ -17,16 +18,16 @@
> =20
>  /* ethtool.h expects these to be defined by <linux/types.h> */
>  #ifndef HAVE_BE_TYPES
> -typedef __uint16_t __be16;
> -typedef __uint32_t __be32;
> +typedef uint16_t __be16;
> +typedef uint32_t __be32;
>  typedef unsigned long long __be64;
>  #endif
> =20
>  typedef unsigned long long u64;
> -typedef __uint32_t u32;
> -typedef __uint16_t u16;
> -typedef __uint8_t u8;
> -typedef __int32_t s32;
> +typedef uint32_t u32;
> +typedef uint16_t u16;
> +typedef uint8_t u8;
> +typedef int32_t s32;
> =20
>  #include "ethtool-copy.h"
>  #include "net_tstamp-copy.h"

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-l4ah/L0g1n44VlUvfGB2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVI3Y7ee/yOyVhhEJAQpjEBAApjK6g9Dt46mpVk2llAX2ejJZpfjmbzL/
wc/pqzgnVWOjMRVeJRDg3nSJk9qQ+KG4W3gnbluH76iCRmxdHaCAsuYm4Hhplrxt
VRqSX04MgPDYYXUDa1gF3mL5UQZ/TA6EdbnpkiS+onELug7rvzQNhVW7t7ECSm4/
FM5zhvYlC1qM7Oi2UxtEPEmaIWwm3K2Sr00oKDP0gFD19I6qdOKLUZ9GMyh3pWwC
FPoQ1A6OzxF6l1TqJRRP6z9uu9VFBgZ8Fjuh48Al7Wac/Bk+WUk618EkFBUzZqnf
CVHHI9ItWcJKMD90qZfxHsAOJuU5F7v1U7QS7YMqvNT3YOh7GpRCCUma946qTtlx
qczPBa1Jc3VB4oqhdb1AtPY4TzvIOvI2E2l3upz71xzBzFiLyFsy2e3fEBnSCN7k
GJ87nBZYwX1ea9Y45FCcr/drIHG6+aV+WwZYgga8f4QHAX9UHKS3N7De8FJiKIMu
YCPl9IcfSE9EX2z+uXE836YusiwCHpp7pRvka5jXKjbEOKRfMRk5j3lLN7nTi6kR
ZgzX6TcV4Iop16kPcDdqzvYnTfptPmtrna5QZ3rVSQi998BWcVeTlF6NHZJkoe0W
y2s49m9FWoWYsV0OlZxxfXu5rliYazY3lNOOfUPX28IIZSBAUDF5e504yUZVDz3k
lsTm+TtHbD0=
=tPc1
-----END PGP SIGNATURE-----

--=-l4ah/L0g1n44VlUvfGB2--
