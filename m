From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH] cdc-ether: Assume link is up initially
Date: Wed, 06 Jan 2010 01:47:15 +0000
Message-ID: <1262742435.26813.61.camel@localhost>
References: <1262741203.26813.58.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-UfG+H5/soAuhL60puMTi"
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1262741203.26813.58.camel@localhost>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-UfG+H5/soAuhL60puMTi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2010-01-06 at 01:26 +0000, Ben Hutchings wrote:
> The bug report <http://bugzilla.kernel.org/show_bug.cgi?id=3D14791>
> implies that at least some devices will not send a Network Connection
> notification if the link is initially up.  Further, the CDC-ECM
> specification states that '[n]etworking devices are typically "Always
> Connected", spending all of their time with the "link up"'.  So it
> appears to be safer to assume the link is up and to rely on the device
> to tell us otherwise.
>=20
> This is a partial revert of:
>=20
> commit 37e8273cd30592d3a82bcb70cbb1bdc4eaeb6b71
> Author: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
> Date:   Wed Nov 4 15:29:52 2009 +0000
>=20
>     usbnet: Set link down initially for drivers that update link state
>=20
> Signed-off-by: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
> Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> ---
> This should be tested by someone with one of these devices, preferably
> you since you reported the bug.

Mail to reporter bounces, so someone else had better check this.

Ben.

--=20
Ben Hutchings
Horngren's Observation:
                   Among economists, the real world is often a special case=
.

--=-UfG+H5/soAuhL60puMTi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS0Prnue/yOyVhhEJAQLyjA//Uya3Ur9rXCBEzLoA74Xj+U7DF+64xWZh
DU5GHdKn/HJUVjRx9sXSPPJlaKy3qavKsKp3QwDGkPT4RTZexKLy8YPo0/y144b0
yqHACqKarRVRUNkNK89miqMyJMYMTET/llE2/UfLWoS0WrCXTi3Dx1MFo6PtA9pE
eGbGc7GUNIPcBaV5w5AOYIzGRMu10tSQNuA31/J7YK1q0mlvL6SptijbbaWpTQBF
Rpk2RBHyRIngvIVejwNybZlbf8rQWpW7H7LtzUAQfWFpysaPMgd+wDwPamyrkIkT
NGs3nLBn3/GbANf68XpjkwFnVX5ls6/gGDNRUEfCI4k/WOUqX5lWtodSsxbiM3H7
d1UgjvOG5W/3+NewrrFQvMPnJtDJwI3y6X86o8d9gobF8T65JgWUip7o4v6sd9jy
C0L+46lTXssngXUSlesu36H/ha1VFs6IelrmNTOEYUO7hWbGlhM4bzRGPtzReyIt
MzGFCkqcYPAhrVdixzcdlp6bCDwjNXTBi37s2MUFMYsHLClAWvLW3uSAKXrbIE4j
TkK8TndJsD0ChW2o/v9cUwrmJl5lsohTm72agg5oE1h+603wSzFKhH4FbPN9HtzP
A/cZ5Ks458Af5e0EVIe2ZWqn3sDj0X/fTG/45qCqTbaR4FSMsB2+BE2y3aOOWJnf
GGBpILULAbA=
=y57m
-----END PGP SIGNATURE-----

--=-UfG+H5/soAuhL60puMTi--
