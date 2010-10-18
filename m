From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#595265: linux-image-2.6.32-5-686: Nerwork card fails to
 come up again after suspend
Date: Mon, 18 Oct 2010 23:48:00 +0100
Message-ID: <1287442080.20865.151.camel@localhost>
References: <20100902154312.12515.10390.reportbug@bird.umass.edu>
	 <201009211624.12744.aboelens@engin.umass.edu>
	 <1286760421.2955.287.camel@localhost>
	 <201010171116.00514.aboelens@engin.umass.edu>
	 <1287361431.20865.133.camel@localhost>
	 <20101018214536.GA14344@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-oEBQvwqwUZFWue8W/0iD"
Cc: 595265@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: Arnout Boelens <aboelens@engin.umass.edu>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:47062 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933161Ab0JRWsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 18:48:09 -0400
In-Reply-To: <20101018214536.GA14344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-oEBQvwqwUZFWue8W/0iD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-10-18 at 23:45 +0200, Francois Romieu wrote:
> Ben Hutchings <ben@decadent.org.uk> :
> [...]
> > Arnout Boelens reported that his RTL8111/8168B fails to link-up after
> > suspend and resume, both under Debian's kernel based on 2.6.32 and unde=
r
> > 2.6.36-rc6.  Full details are at <http://bugs.debian.org/595265>, thoug=
h
> > the log isn't very informative:
> >=20
> > [31837.396594] PM: Finishing wakeup.
> > [31837.396597] Restarting tasks ... done.
> > [31840.267267] r8169: eth0: link down
> >=20
> > Can you suggest how to investigate this further?
>=20
> Something like the patch made by Stanislaw at :
> https://bugzilla.redhat.com/show_bug.cgi?id=3D502974

Thanks.

Arnout, please test the patch
<https://bugzilla.redhat.com/attachment.cgi?id=3D454034>, following the
instructions at
<http://kernel-handbook.alioth.debian.org/ch-common-tasks.html#s-common-off=
icial>.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-oEBQvwqwUZFWue8W/0iD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATLzOn+e/yOyVhhEJAQIC6RAAiN9K1psE8exETOfA4+JlAjhSXps5Y5Tb
qG8GQ9A+kvjeFMJ9zkurLZVY3LUtbq92xET2wfnV4LTGfrQq2ZWf2g1hW2ktLR5G
Up16U2haGvSdrdUgaKH4NYCce5Q3wEF/xDBcAPQoqOGb7ooL8jHfB20k1dO4llVK
1Y+d4nBgGyvShjoyEdoVyJabJOt7qytLVvmrYbajiAhk+6j5lDiRz+137B59NTNB
baxvexrHwTBZDZS0VfeIit7BggQbm7/KM7uAHdo/RGy660x+HJ+S9/YQOgBFFM1u
UT8wuS+NlM5bnrgMLrZcEkHB4n4/onjjvFCr8dJiKMxVBUH9hw9TSAQgZSxa0nOm
knoUfekqNZRQd7jRRksNyH9jqw+bfDR0vaDsVSNxCfIYvlln3w0i2Iuplva8sRGl
5OFvP8Mg6GFcC9aLhaiZTai5d+r672z3D1nK39/YiZSrlHOOSv2RCMHaLnpPNtEM
BB1+xITaN/IRAkRjLSCpep/YgDCOD18aYNgryNBWm8G4GOkIi8G9N9SYmiUcVIe+
nOXG1b26RDuUkcDmtIE+M+zD1SFVhuvtYIrEcAjTuN9Odid+40yNUPF5+ark8il2
Bz2ANjeYRzH6xike9bDVDjXHSlg4yOvCkV2EtsIsup/aO6ZnwHqSu/z75HIGeO0C
R90/WlO77Uk=
=8MKX
-----END PGP SIGNATURE-----

--=-oEBQvwqwUZFWue8W/0iD--
