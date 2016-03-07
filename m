From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [ethtool PATCH v3 05/12] marvell.c: fix strict alias warnings
Date: Mon, 07 Mar 2016 16:06:47 +0000
Message-ID: <1457366807.15205.22.camel@decadent.org.uk>
References: <1457138533-2417-1-git-send-email-ddecotig@gmail.com>
	 <1457138533-2417-6-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hbHMyUuSwguBWczh65ku"
Cc: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Decotigny <decot@googlers.com>
To: David Decotigny <ddecotig@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43677 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752900AbcCGQGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 11:06:54 -0500
In-Reply-To: <1457138533-2417-6-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hbHMyUuSwguBWczh65ku
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-03-04 at 16:42 -0800, David Decotigny wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Addresses the following warnings:
> =C2=A0 marvell.c:426:2: error: dereferencing type-punned pointer will bre=
ak strict-aliasing rules [-Werror=3Dstrict-aliasing]
> =C2=A0 marvell.c:427:2: error: dereferencing type-punned pointer will bre=
ak strict-aliasing rules [-Werror=3Dstrict-aliasing]
> =C2=A0 marvell.c:428:2: error: dereferencing type-punned pointer will bre=
ak strict-aliasing rules [-Werror=3Dstrict-aliasing]
>=20
> Note: code appears endian-dependent, not fixed by this commit.
[...]

LGTM.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g
--=-hbHMyUuSwguBWczh65ku
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW3acXAAoJEOe/yOyVhhEJTCkP/0geMYj05MtrzImJ9cdQUR5s
r0+ggVSpvnbcmgaAIKsRzsR1LqV/zdaxRA6EStxnCtH14VYnQQyGHTBlFK6KDDpt
8GktaMv7vDAX/xs+CcFmrKfoUNjOaCRPH/uyErSHSy6ZACHXfWlOS6kz+ZJBB0Fa
QoJrigJPBqf8b7At7yS4INuOkl5PuggVE2AhvYyodIPLPV4EgRIXZuGdMN2p7dJq
QPjbpdIb4XRE7MyOTsMGacBXSE6KM8pWRpGz5O3EkMASNG8HaakQdp3bze5vjkzy
LIp1Svzc/XRswNM5iJxrCen4uAIJLM8EfLTOqKTYIpoe40laWytt4Q8kx2yqp1qB
KVfSKiIkfDdwR5g8Tc8xoyPyYdyDUEwdF38HBWeFr4p3DCppB2/Ajv+f5LDfx1eD
csoYeW8bog2jmg0nalaf1D44WdIYZ9zPzZkLVOT2YR0M5QD82V9z7hLRDcVK4G/n
ts2M/FePqMPRJ74leC0S2igkyibshbjmim6fbHrJWWjhzM1icLQN+cbKhTXhMZrm
3w6xtx+ajw6Ad3OrMUJNs1xJd3aHuRgHR/dHfHA+ZkH2NInY+4QF2tEpXRZ6gdVx
pjjl8lPky/tXFJFGs6npBb0S6IW8tbbCoqNXFfyE/YWIsqweHDxh84Bby6StPmVr
Mf1/het+E9kGnsP3GX9+
=RGd3
-----END PGP SIGNATURE-----

--=-hbHMyUuSwguBWczh65ku--
