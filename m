From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH] drivers:isdn: Remove uneeded fix me comment in capi.c
 for the function,decode_ie
Date: Thu, 01 Jan 2015 22:18:51 +0100
Message-ID: <54A5B9BB.7050107@imap.cc>
References: <1420053714-24661-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: isdn@linux-pingi.de, gigaset307x-common@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>, hjlipp@web.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420053714-24661-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Nicholas,

Am 31.12.2014 um 20:21 schrieb Nicholas Krause:
> Removes a no longer needed fix me comment for the
> function,decode_ie in the file, capi.c. This comment is no longer
> needed as the commit this was written in was 2009 when the new
> driver,three was introduced. Due to no breakage related to the=20
> newer version of this driver we can safely remove this comment.

I won't oppose removal of that comment. However your commit message is
not quite to the point.

The comment poses the question of whether the conversion to upper case
done by the toupper() calls in the two lines following is actually
necessary. The fact that there is no breakage with the current code
does not answer that question. It could only be answered by *removing*
the toupper() calls and *then* checking for breakage.

However the cost of two toupper() calls seems so small that it's
hardly worth the effort and risk and we should just leave them in.

Regards,
Tilman

> diff --git a/drivers/isdn/gigaset/capi.c
> b/drivers/isdn/gigaset/capi.c index ccec777..d55ba3f 100644 ---
> a/drivers/isdn/gigaset/capi.c +++ b/drivers/isdn/gigaset/capi.c @@
> -182,7 +182,6 @@ static void decode_ie(u8 *in, char *out) { int i =3D
> *in; while (i-- > 0) { -		/* ToDo: conversion to upper case
> necessary? */ *out++ =3D toupper(hex_asc_hi(*++in)); *out++ =3D
> toupper(hex_asc_lo(*in)); }
>=20

- --=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=F6ffnet mindestens haltbar bis: (siehe R=FCckseite)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBAgAGBQJUpbm7AAoJEFPuqx0v+F+qxFcH/1F6l/1ycTikNdwfsHesZW6Q
TXDO7YfguLDe+wyePEvHdBFW+AwEgGFWTz2EEqfpdu/dHwmWjZh8yTLkJEMfn4fz
jBDm2Kyw+uFzUSXPVCyMUNXgC7yATs6l2AEkX5FSr0BycUVyMIeemChB4Pf5DfQD
B1Lz86xKhM3HpdI/KIDXqqHK88mT/B+7+rUL6lyJ6GRU/168EetD5PzjXoQ67DUw
JaSpCTjf1nUQAL1Nw623QVT4le/vPXLhwpIIAhLmvwO3nn8XWx4WdiCGVm6bGgrV
coWwo8LRB/IMCwoZGh2RhmDy2nOYwj1k9NYLjrx+izhbQUSpwqoLUCZe6vhBTks=3D
=3DPpmw
-----END PGP SIGNATURE-----
