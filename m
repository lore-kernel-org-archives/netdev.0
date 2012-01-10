From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Mainline kernel has problem with broadcom firmware
Date: Tue, 10 Jan 2012 02:14:49 +0000
Message-ID: <1326161689.3432.26.camel@deadeye>
References: <CAP+Vy9f0wMXebtfMWBXdC24cQR1d-2i6YZxfjK8JyOpVGgKvrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vXz5GgwG/VCtr7XDd3z2"
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
To: Dongsoo Nathaniel Kim <dongsoo.kim@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34307 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932271Ab2AJCPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 21:15:02 -0500
In-Reply-To: <CAP+Vy9f0wMXebtfMWBXdC24cQR1d-2i6YZxfjK8JyOpVGgKvrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vXz5GgwG/VCtr7XDd3z2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2012-01-10 at 10:12 +0900, Dongsoo Nathaniel Kim wrote:
> Hello folks,
> After updating my kernel to 3.2 vanilla, I experienced a weird problem
> with my broadcom ethernet card.
> It seems to have some problem with firmware which is not placed in
> kernel firmware directory.
> When will it the correct firmware be available in the mainline?
> bnx2-mips-09-6.2.1b.fw <=3D I mean this one.
> I hacked bnx2 driver to use bnx2-mips-09-6.2.1a.fw and ethernet is
> working, but we really need bnx2-mips-09-6.2.1b.fw, don't we?
> Cheers,

You can get the new firmware file from linux-firmware.git.  It's a bit
stupid that we have the old file in the Linux tree though.

Ben.

--=20
Ben Hutchings
Life is what happens to you while you're busy making other plans.
                                                               - John Lenno=
n

--=-vXz5GgwG/VCtr7XDd3z2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATwufGue/yOyVhhEJAQpQcA/6A/7U0U7+NA8+4cSKoYTsy56Gj/v4U0z0
Mj7s3s4yL/H6spreTcySvK4VtY7uN5Jg0v++g1uZrLE+SXRGGDdfG7zHmnQSpo4p
kOnNWAqVE+V1t9uroCwAAP06XG7eaX2VkIfI1iF6GkDyWH4LCiOCvsizmGlzDKwz
V1LsBeb7tz5nklXP5TX+khtuNdXfGw+gf41RkezH7vLXKPrWDnCBVoGokGlJURYf
kB96gXKjjfWHBofzVxxIzkCu5JyX82A1i+D+pmzjDY8ijaeTDhyQWR17D/V3xW9+
YihOfLjGgA4G0ZK0GgiIPFTzEwZgLNP+b+zcE3SnZ0F3xyVOfXvo1rOvE32BrNhk
GEeiAWT1ppY0NyLF6yUgNVzWUunoWgXsNrsCpaCfCN1qiUlPTdCG0qa50cTgoZgI
qLs6Ns0rQn+SpQVyMUKhvJ7TIvhedajowLQM3n1TBoTN8QdspYhP2+NfTKyRYDtX
+4ofz6NTXYjhJQ5woaIeClL1Pb78kY4o57YLzxENGzQ3Fe3q/TqosmcXklU2sAYZ
cr5k58ezHxW+GZjDylIcpZBSrx302FjJ1k6LWhgNOVpkRtN3yLBPJn7RHn0lJLSP
LUgjxL3+V7yy/A9lSEo68ZMsto3H6IV1S9nWhrDVEUeCaH82NB7JqagjiMvNNTjc
mO2qqOa7L1U=
=cT1c
-----END PGP SIGNATURE-----

--=-vXz5GgwG/VCtr7XDd3z2--
