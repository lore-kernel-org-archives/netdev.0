From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH iproute2] ip xfrm: support 64bit kernel and 32bit
 userspace
Date: Sun, 30 Nov 2014 01:33:22 +0000
Message-ID: <1417311202.7215.109.camel@decadent.org.uk>
References: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-vDvJSK8bNyezsZ5IUfTl"
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57997 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751684AbaK3Bdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 20:33:35 -0500
In-Reply-To: <1417157936-5522-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vDvJSK8bNyezsZ5IUfTl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-11-28 at 14:58 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>=20
>=20
> The size of struct xfrm_userpolicy_info is 168 bytes for 64bit kernel, an=
d
> 164 bytes for 32bit userspace because of the different alignment.

I think it's specific to x86 as other architectures have the same type
alignments for 32- and 64-bit variants.

> and lead to "ip xfrm" be unable to work.
>=20
> add a pad in struct xfrm_userpolicy_info, and enable it by set
> KERNEL_64_USERSPACE_32 to y
[...]

This doesn't make sense.  32-bit compat needs to work like 32-bit native
- no exceptions, no workarounds in userland.  And if you really want to
work around this in userland you'll need a run-time, not compile-time,
check.

Ben.

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-vDvJSK8bNyezsZ5IUfTl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVHpz6Oe/yOyVhhEJAQqC0w//Z/tb/vH8FqmoZZCy0b/7kWazmsJNpW6K
oUx4NdXqSFOtu0ItS7UFDfA+idwn4gAKil3tyAeIigwz2hbZnKF1MOD4fRVr5jAH
72C57ZbdhJ9yIcSCEgpYH11skHVHgSftIDbvP//jhLsDn7827e3LcoByz9nSdD5+
JxbvmL/tAJ9FMBnieXdknwWH9KLpOi60bR572lpAupMpzeTcwhUyUKQ4spsacEs2
SjnypF47uWxVCYRd3DcyRruC0jPYxBbIbf+YgRMSlTOWqRlP/CKh/dCnjnMFmOsb
aKIT7G/h6znUkmieQPiBJXzozYGHCDOqAEYPJEPLvu2wmYL255Vg/CVdYC9Q//xk
i1jvbpcE1M1jkmenogkuSpd+dBycL5q9enybmNwugvSXetiWJQMN0h/LHIxm+7ZF
Tf1nRtk6Eb64z6HlhvjoGfBb6ucgtsA1DhtD3iis9TFQiSwVxnvXRQCUY2GfMmVE
RCBFZksryZhSTHgNLkhKcQitqgKePsg7xzeIwIKMbebaoFLR8t88EZUQIsCrRhws
QlTr76eHUtiatGSNuI+lXyASQKJ9KhCIjpb66LKOqvNBZQ6ANo+K5kUSDa6WRIcx
bDpLmkfW9BOL7s6ziKYksUnCiycFUhEL51KD2/dLOJEMLFouVihfz460F8ssjAfD
4BBn79xL8bs=
=NkV/
-----END PGP SIGNATURE-----

--=-vDvJSK8bNyezsZ5IUfTl--
