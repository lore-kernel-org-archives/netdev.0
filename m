From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Sun, 07 Nov 2010 17:11:06 +0000
Message-ID: <1289149866.2816.69.camel@localhost>
References: <1289074307.3090.100.camel@Dan>
	 <AANLkTimC01SViEOObgf2N2VcLTYO59rOAbHaKf2RM54w@mail.gmail.com>
	 <20101106.165703.193714684.davem@davemloft.net>
	 <4CD67F38.1060506@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-tn0vObSOrrp6rBRo4Moc"
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	drosenberg@vsecurity.com, chas@cmf.nrl.navy.mil,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	remi.denis-courmont@nokia.com, netdev@vger.kernel.org,
	security@kernel.org
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38620 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751882Ab0KGRLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 12:11:50 -0500
In-Reply-To: <4CD67F38.1060506@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tn0vObSOrrp6rBRo4Moc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2010-11-07 at 11:28 +0100, Oliver Hartkopp wrote:
[...]
> The layout break was ok in this case as the people using the CAN procfs s=
tuff
> do this only when facing problems (with their applications) at runtime.
>=20
> A discussed approach that won't break the procfs layout was to set the va=
lues
> to "0" and only fill them with real content depending on CONFIG_DEBUG_INF=
O .
>=20
> Would that fit here?
>=20
> Or maybe a different config option CONFIG_DEBUG_KERNEL_ADDR would do the =
job,
> as i don't know which distros enable CONFIG_DEBUG_INFO by default ...

I believe most distributions now enable CONFIG_DEBUG_INFO (though the
debug information is then stripped and shipped in separate packages).  I
also dislike this idea of an implicit trade-off between debugging and
security; such a trade-off may be necessary but then it should be
explicit.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-tn0vObSOrrp6rBRo4Moc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATNbdoOe/yOyVhhEJAQLTJg/+Ml9SLU4kz4Rwkv50E7JuhKYC6nXj3za9
Wux7151hfCK2S1W+BYXuYT1dJvdjaQZiP4gCcL7M6qc6xqK6Nm1htmh1GrJkDDIL
JuO5OCegbb2A1YgyYvwuVhv03z4sjedkulWtBSXjwmNFOg4Uj986kIL2gZR3Ahei
QAx0eOkgIaCo7vfiFutf6kclBiO/Ec3t9wMaRNPEfyqyQTNsEaDVvnh1mawWfvMJ
nRYe0nAZDRZbmlxMDAafKHCxQR7zKISBlDRRj2tf33GyusrqsHyvztscDQJNimyY
JIv9VFdnji/t9FF0hogXWQKUk3rUhc3QMcOGY5FWo3Eg3TpFSahhk2sbJpJTEBKH
4NUAJ/jN7jNXqOcVh6f2c4kUKt0olP8SlTJphXcshU7SHtVUI/ZKwvNogA+JFCjJ
gQjcrbuhaeAxcjtnjbCC0CQpzYfsDtJ0ybh6vae6qk0M1vpXHPo0g57djg4OZ+cM
qesdHSosX0xkO1inLVHzM/rXgJEZKsWGl/HpK2AVYXXXYtJ63UgDn+xzr+TWRxWe
dgE3Q73AAsYmgGiOPMn2NDHMQoEjAJpe+O2WlafG5So15rtLLF5zNXkSMH6YWfx3
DBnjlFVs/VWC/3m6gZnHK/8txf8n18tVf1RyRlEc+3S19FCqCSLt/4nIH5zRRdrY
HSi/7uxhSoA=
=Bpx0
-----END PGP SIGNATURE-----

--=-tn0vObSOrrp6rBRo4Moc--
