From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sungem triggers NAPI warning
Date: Thu, 21 Feb 2008 14:05:25 +0100
Message-ID: <1203599125.4427.0.camel@johannes.berg>
References: <1203457124.3874.2.camel@johannes.berg>
	 <1203562472.10422.102.camel@pasglop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-yEpCc4LxY+m3jMRykiFe"
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51465 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758612AbYBUTUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 14:20:36 -0500
In-Reply-To: <1203562472.10422.102.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yEpCc4LxY+m3jMRykiFe
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


On Thu, 2008-02-21 at 13:54 +1100, Benjamin Herrenschmidt wrote:
> On Tue, 2008-02-19 at 22:38 +0100, Johannes Berg wrote:
> > I started getting this warning with recent kernels:
>=20
> Do that help ?
>=20
> In gem_poll(), do:
>=20
> -  work_done +=3D gem_rx(gp, budget);
> +  work_done +=3D gem_rx(gp, budget - work_done);

That looks correct, but I haven't been able to trigger the warning again
even with similar workloads so I haven't tested this change because I
can't even reproduce without it.

johannes

--=-yEpCc4LxY+m3jMRykiFe
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR713FKVg1VMiehFYAQK0wRAAs4Z2380WZXg/u648JWoE/7F6RxnVMZeF
X0VyaU0dRJf3klpOoOUaCF5mCg0ZdmHmBxjPrLaUUhyMWBiNDFS+d6rngeXtboDx
+A2lJo966WdKRJUi5ztJu6/REP6u72Yvv1GWNouWNAOFj9405TQG+tdUW29Ivjt9
i9YUe9ljO7CiCnhX6h8uZWUkL3s36UL/qzXrbKP6yn5sgHkXmoCB6UOQ2DIgACgR
5wDNSm7tLmTLv8Qm8aGn5hYqZJFcXqKKuWoWDalJJUxU3VHVACumLRiqFU5MAmOq
9aewIzhYeTCCjtCvUxMwq0XsoDzwgbgEuQqH1FY6WAmZGLg4MGF3/lU5vgYr0GNB
zR2ntY095gcasOnoM4Og5Y9V0dhN+rLDyogaRLwMwc6OCffTGWyNS0+XcTemTLco
10/AINBafIqExIJKXhVfontGPj78mo3LuVTBLE6ewQcsxZPUVscckadSAL75RJak
VOl1f3Ano53Y5MEqkgvh0Ctc3nlrnu19ufDI1dm68mam4rSh0CJkap1+qNyoycho
1Xz6HgaZ+Qzpzzy5i8r9U2vsDUu4lIo0P44xCeRGw/J2rHrIW5nUNlscDo4HadbI
X/gQlQv6PL0n62gHTDYCT+KAxNQctXRyZhTU/tKRsbhXF0zTetsfjQ+r9L/TRPV6
KgGzhYHJf+4=
=/G4h
-----END PGP SIGNATURE-----

--=-yEpCc4LxY+m3jMRykiFe--

