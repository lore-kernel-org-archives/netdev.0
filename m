From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] mac80211: disallow bridging managed/adhoc interfaces
Date: Tue, 17 Nov 2009 18:05:48 +0100
Message-ID: <1258477549.21197.2.camel@johannes.local>
References: <1258465585.3682.7.camel@johannes.local>
	 <200911171504.54170.mb@bu3sch.de> <1258466868.3682.13.camel@johannes.local>
	 <20091117083741.1b165274@nehalam> <1258476223.21197.0.camel@johannes.local>
	 <20091117090420.0434edc3@nehalam>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-ZgBSg+gR/nri1bMeRNE7"
Cc: Michael Buesch <mb@bu3sch.de>, netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:48894 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755665AbZKQRGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 12:06:13 -0500
In-Reply-To: <20091117090420.0434edc3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZgBSg+gR/nri1bMeRNE7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-17 at 09:04 -0800, Stephen Hemminger wrote:

> Then how does this work now? And will your change break it?
>=20
>                              kvm1
>                             /
>      =3D=3D=3D=3D> wlan0  --- bridge-- kvm2
>                             \
>                              kvm3

What's the type of wlan0? If it's managed, i.e. connected to an AP,
it /doesn't/ actually work now, which is my point.

johannes

--=-ZgBSg+gR/nri1bMeRNE7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAtfpAAoJEODzc/N7+QmaHIAP/3+P6EQ+UCMCUyF9r7FOoMeY
CQ6S0Rza+5YMYAL1c4cMcnTSzsfBgq7011KrMmjnnKFwCc4wVaRhIL+48zjDv6tx
3tV2rysmbMVanya4ax5wyx2slfA6EtaFZSZqgH4aPQlUXUsu8bICbHi2dtFmJcb+
YIL1Sd7dRVA4cv/YO9KTSyl5KJ+K593tY/2uSsjIgzFfx8D6ztoE0um0knTfdzVx
o2ZL1II7VLM2wD06BNdbMC7s935KGc/77+f0J19E6gLquMDW94KJUQm4oQxVFQqW
3dj9Q3shjYp24xnGM3Rm5lARCDylnCT/HoGb0OCSGGK3+lVoebYWN2xOqKuWn6p1
DbjXDw8jXGz2uDifNEElxaIZ3Ss71vO+JY5Wi3sebTPPeNm4q9w9kQ+xsIwYEyc/
2NPaNciDdtSIVvK5X6Dlf7fv/EXCkrE+GFB9T3bVq5ge61D36YOPQ5jpiVfPa7+R
pWoB9mDpyGjdeciqdosRxLUkU7sqx+iRh0Wi9ZJNv2DLlEH1y2jzv3cXeLWDBbEl
yeMZCF+Ui2b7IFT974VPxoqBAgZWelQuLhF2rIPEHb1X8+CG1syGLuualtVJusDH
e4JGr1OGXogKx5DDssBa3LinyAcTvAUOWIWq9/YtjwPE8pxN8vDVnlIC9Tmf7T/N
41btUA/H6XXDfBRD+s8o
=4ak8
-----END PGP SIGNATURE-----

--=-ZgBSg+gR/nri1bMeRNE7--

