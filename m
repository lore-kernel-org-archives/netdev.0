From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Mon, 29 Dec 2014 09:50:29 -0600
Message-ID: <20141229155029.GA29379@saruman>
References: <20141204165609.GJ18045@saruman>
 <CAGm1_ksNuO75QfgaDUpOe525xDkPhby-z8T=MX3DHdB-LVcR8g@mail.gmail.com>
 <20141210171724.GI4602@saruman>
 <CAGm1_ksziwSjQnV1rDYsAv2QQCvhnZPOimowmsW5Cib7C01aqA@mail.gmail.com>
 <20141210210234.GN4602@saruman>
 <CAGm1_ktYg4iDgK7jyi5etSVup61LdookkV+SaQZOpLb6M=y7hA@mail.gmail.com>
 <CAGm1_kuaqXrU4zhNUZeY85+OeXHApSUDjJdsXcyBdvHTNhLCmQ@mail.gmail.com>
 <20141212173210.GI7549@saruman>
 <CAGm1_kuYrGsfjRO6TVr554yS8dcD4_Z9-j9KL0xpD=X+31OkXQ@mail.gmail.com>
 <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="EVF5PPMfhYS0aIcm"
Cc: Felipe Balbi <balbi@ti.com>, netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39301 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbaL2Puz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 10:50:55 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_kudtF9O4QChrKX1q=c9KwHEFZet=z7j=-_iCRE914X83Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--EVF5PPMfhYS0aIcm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 29, 2014 at 10:33:26AM +0100, Yegor Yefremov wrote:
> On Fri, Dec 12, 2014 at 8:19 PM, Yegor Yefremov
> <yegorslists@googlemail.com> wrote:
> > On Fri, Dec 12, 2014 at 6:32 PM, Felipe Balbi <balbi@ti.com> wrote:
> >> Hi,
> >>
> >> On Fri, Dec 12, 2014 at 01:00:51PM +0100, Yegor Yefremov wrote:
> >>> U-Boot version: 2014.07
> >>> Kernel config is omap2plus with enabled USB
> >>>
> >>> # cat /proc/version
> >>> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> >>> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> >>> Mon Dec 8 22:47:43 CET 2014
> >>
> >> Wasn't GCC 4.8.x total crap for building ARM kernels ? IIRC it was even
> >> blacklisted. Can you try with 4.9.x just to make sure ?
> >
> > Will do.
>=20
> Adding linux-omap. Beginning of this discussion:
> http://comments.gmane.org/gmane.linux.network/341427
>=20
> Quick summary: starting with kernel 3.18 or commit
> 55601c9f24670ba926ebdd4d712ac3b177232330 am335x (at least BBB and some
> custom boards) stalls at high network load. Reproducible via nuttcp
> within some minutes
>=20
> nuttcp -S (on BBB)
> nuttcp -t -N 4 -T30m 192.168.1.235 (on host)
>=20
> As Felipe Balbi suggested, I tried both 4.8.3 and 4.9.2 toolchains,
> but both show the same behavior.
>=20
> Linux version 3.18.0 (user@user-VirtualBox) (gcc version 4.8.3
> 20140320 (prerelease) (Sourcery CodeBench Lite 2014.05-29) ) #6 SMP
> Mon Dec 8 22:47:43 CET 2014
> Linux version 3.18.1 (user@user-VirtualBox) (gcc version 4.9.2
> (Buildroot 2015.02-git-00582-g10b9761) ) #1 SMP Mon Dec 29 09:22:29
> CET 2014
>=20
> Let me know, if you can reproduce this issue.

finally managed to reproduce this, it took quite a bit of effort though.
I'll see if I can gether more information about the problem.

--=20
balbi

--EVF5PPMfhYS0aIcm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUoXhFAAoJEIaOsuA1yqREMEMP/0V1S5OySRsUUujYOfll4LNB
NEvayDpYheJHLtc7plSO6zEd9X6JwBnBanFkJhxfEiJsDHURD1V8omJzEHE0+SQc
4+LbYfc2/TeSiKASMzcAzAmt+KQ4sDPFo6oxZvlyP1mtUTmj1L2t4BFZPcwAyO5m
hAK0noy6TH2ywBNcDIqn2EBcloObiXy9RhlLB782exdgdSKB//XS6aYuVbtul9/p
hoqt2uP732Zvp/iNkZ2unDG6AoXRFL6CKq6OIV3kyBvOxRqi59Dj08yviGLb2O82
I2GgAWkI8vytUtaKljlC2WZ9qfOUGQzKkkXOjRH1Uvz3dqj0MbrRg/0PoDRzveki
krpQzgZloem5khknQCgkrCxCafa2QWs2uNPy0QUJify5eGMiHYSTFN6+/+8v/3fM
88C6aHcWdO5j77yjR5nXHTP5ZRUQzTrrLNKeO+nUc38pptDKWofJuYP6TwN+GfNv
YvNXNQODVecbR4cyhaJ7soMk4LUqE9rqwj0xE7jffa0b1wKAb8yclx3/3wggqRfV
S2g/kY6yDyNOTyT9s5kpQGmbJ3HqiiUEEM+2w74JqwzG9IcxhtgSK1E4bOTBVxbv
LNzZWrRsejD1HhQ1gW79EdmrQ+wXKVhwGEh91KDa+FiDqsEfH0by5K+HNpDRAC1z
Lhcd/DA+dUkqzUgJy3nw
=Y5Mr
-----END PGP SIGNATURE-----

--EVF5PPMfhYS0aIcm--
