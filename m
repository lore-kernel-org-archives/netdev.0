From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] net: Revert ARCNET and PHYLIB to tristate options
Date: Fri, 25 Nov 2011 18:40:42 +0000
Message-ID: <1322246442.2839.358.camel@deadeye>
References: <1322119410.2839.262.camel@deadeye>
	 <20111125.013102.841551383223873520.davem@davemloft.net>
	 <1322230071.2839.337.camel@deadeye>
	 <20111125.132220.150546128040363058.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-MiHUV+sa20Pf2cxa8geq"
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	debian-kernel@lists.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:60221 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960Ab1KYSlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 13:41:01 -0500
In-Reply-To: <20111125.132220.150546128040363058.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-MiHUV+sa20Pf2cxa8geq
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2011-11-25 at 13:22 -0500, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Fri, 25 Nov 2011 14:07:51 +0000
>=20
> > Well, I can't think why it would be built in, since PHY modules can be
> > auto-loaded now.
>=20
> It's because drivers select the thing.

Drivers are also built as modules in a distribution kernel.

> Try allmodconfig for yourself.

OK, on x86_64, this does end up with PHYLIB=3Dy but only because
NET_DSA=3Dy.  And I don't believe NET_DSA is appropriate for a distro
kernel.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-MiHUV+sa20Pf2cxa8geq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATs/hKue/yOyVhhEJAQo3ehAAx0Yc2Hlj3dneB3hx/IpCY6ZMUWg1gAru
CHKmiFrhVx+mVxJDnWSTHc9nQoSYcDou37L1xwjJ7tmOpZpykTP3EAurVFfe14Io
D+Gf9yXn1p3okGvTqszY8jo5DqHExLpZ0fEPFGgEjfsmmFhaiWNcQ2qpBDd7whs4
TJzKM/ZvsHxdK2kMA2NtLzHc6JNUQLOsnuSHGopVucq35gBG6QCJvX0DLf4vN9Z4
23WoI8xRvwk5GeF3WrhmKKyrV5zfC4LCFOr9XQ8jtOTbNEOjT5142YlGkXKJ1/Ed
SiNKvTJlhDZrtfYMcIIergULbbIh1x6kvyyl4WMWIG5/DU6Rzn+Bd5B+7i0gTaPw
IC86eH6vhQJeuSAi3ECHN7kxoevxyQExz+APC9XAPjFPBQO8+KkYls8Un3+bKg3c
bWStnIkeX0psHpEmHS70TGWQzZPQz3qcv44VPt/VdMrCgvBRT+pa6itnhvyJ3mHV
9SeZO0XKAnOaci1S4mIsVfRxi0JcM+LWOB3fO3Z4XWKVu3de/UWxmlSWrppRpzrY
ohssatISxm8s3VkDau7kuhpd9fZmyYe5ceArkm2VRgQ1xyO0q8VHASwOCxB5x03/
MwtwH6IAFLftwOiy5PcJr37+Sab2kmotSrPW7QIKR4LTFQmYPrMqUuaf2V7LWuyE
vbouVQzy99I=
=PY+f
-----END PGP SIGNATURE-----

--=-MiHUV+sa20Pf2cxa8geq--
