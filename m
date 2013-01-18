From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v2] [iproute] ipxfrm: use alloca to allocate stack space
Date: Fri, 18 Jan 2013 12:41:23 -0500
Message-ID: <201301181241.24082.vapier@gentoo.org>
References: <1358476746-10810-1-git-send-email-vapier@gentoo.org> <1358481650-20816-1-git-send-email-vapier@gentoo.org> <AE90C24D6B3A694183C094C60CF0A2F6026B7115@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3483008.4g8bRdevz4";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: "David Laight" <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38974 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab3ARRhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2013 12:37:46 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7115@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart3483008.4g8bRdevz4
Content-Type: Text/Plain;
  charset="windows-1252"
Content-Transfer-Encoding: quoted-printable

On Friday 18 January 2013 05:00:53 David Laight wrote:
> > Clang doesn't support the gcc extension for embeddeding flexible arrays
> > inside of structures.  Use the slightly more portable alloca().
> >=20
> > Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> > ---
> > v2
> > 	- use alloca rather than flexible arrays in structures
> ...
> > +#include <alloca.h>
>=20
> I'm not sure what happens in Linux, but alloca.h is likely
> to try to use the libc version of alloca().
> While that worked 20 years ago, these days compilers then
> to use %sp relative addressing so you must only use the
> compiler builtin alloca() code.
>=20
> With gcc, compiling with -std=3Dc89 (I think that is the one)
> causes the builtin alloca() not to be defined.
> By default alloca() is part of the language and the header
> isn't needed.
>=20
> Use of alloca() also stops some of the stack overwrite
> protection being enabled.

seems like a short coming of the C library then ?  with glibc, if it detect=
s=20
the active compiler is gcc, it will define alloca() to the gcc builtin.
=2Dmike

--nextPart3483008.4g8bRdevz4
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQ+YlEAAoJEEFjO5/oN/WBdGUP/RdZ9s8AgxydyeTUbihGH28v
/XLz7KxYESq0YrMG7wRuYd7Re0a978hEXSpc4Cuc+cUXCyRKFIDOypLWWpaORMsx
ftXSDJc/X0kF9NVTSZfJZ8mo1RmwmSUxTfoupzDy7pARc+RjnByFwmZz2t72+jLG
ByqGAdyEGoynW1duLNrc+G9QG5fe1ca28oLKpQNoy5N+piSwNd1O6XrKaZ6l7U4n
nevtmVgbxeXkK57etu9m2fNC8AMbidDpABtYQpymWt2J+f2cRtgGW9hytrhZRAJv
htvHYBTjO7rTHl1wvOQMtu5bExpf/ExA7yW9FPJ66pN4FPayiIb4/pVShH069w+x
W4cJ5HBfGmPFWWBgAI389v4dQrvKgaU6RbTunuXwcFNldpSiEaN4kXNPLSAd2I2/
LjRdCXGffiz3tj+b4fQbzpc3kHlwBNOi/eKt1aC1jXdydENrMmGx+R4s/nfK4UWM
1OCbo9TyMV3VC4mSgEOdaVWVNvyE2n5HeEVbbVVlDHnjJLABuuP/ovhDO/H61ttg
ip8BT/Z1Zt6n7DVmK4KzzFz+C3lvLKUevFep1aeIFgDD9HhmrTye2u3AzsVkrZJk
AWeoy8egAzHjs84Nhzc8NVl4tUx8tW/Hd61UdB4wTxbE+ZHQR1zA182DAfdeGgJ8
sIre2kCCimb6U0Hjg6Fj
=bUDD
-----END PGP SIGNATURE-----

--nextPart3483008.4g8bRdevz4--
