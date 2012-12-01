From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: Re: [B.A.T.M.A.N.] [PATCH 6/7] batman-adv: Allow to use
 rntl_link for device creation/deletion
Date: Sat, 1 Dec 2012 14:28:02 +0100
Message-ID: <20121201132802.GM24115@ritirata.org>
References: <1353715332-4284-1-git-send-email-sven@narfation.org>
 <1353715332-4284-6-git-send-email-sven@narfation.org>
 <20121201131108.GL24115@ritirata.org>
 <15221362.NFC3M7kpXE@sven-laptop.home.narfation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pFej7zHSL6C5fFIz"
Cc: The list for a Better Approach To Mobile Ad-hoc
	 Networking <b.a.t.m.a.n@lists.open-mesh.org>,
	netdev@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:44596 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796Ab2LAN2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 08:28:53 -0500
Content-Disposition: inline
In-Reply-To: <15221362.NFC3M7kpXE@sven-laptop.home.narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--pFej7zHSL6C5fFIz
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Dec 01, 2012 at 02:16:38PM +0100, Sven Eckelmann wrote:
> Please don't remove netdev from this discussion without a reason.
>=20
> On Saturday 01 December 2012 14:11:08 Antonio Quartulli wrote:
> > On Sat, Nov 24, 2012 at 01:02:11AM +0100, Sven Eckelmann wrote:
> > > The sysfs configuration interface of batman-adv to add/remove
> > > soft-interfaces is not deadlock free and doesn't follow the currently
> > > common way to create new virtual interfaces.
> > >=20
> > > An additional interface though rtnl_link is introduced which provides=
 easy
> > > device creation/deletion with tools like "ip":
> > >=20
> > > $ ip link add dev bat0 type batadv
> > > $ ip link del dev bat0
> > >=20
> > > Signed-off-by: Sven Eckelmann <sven@narfation.org>
> >=20
> > Hello Sven,
> >=20
> > why are we adding yet another API? What's the purpose? Is this intended=
 to
> > fix the lock bug we get while using sysfs?
>=20
> Because this is the normal way to create virtual network devices (please =
feel=20
> free to correct me).

Well, I've seen different iface types using many tools, e.g. vconfig, tunct=
l,
brctl..
Not that this justifies the fact that we should do the same (imho having a
standard and unified way for creating interfaces would be the best option).

But, to be honest, I think it should better discuss how to entirely
moving/changing the existent API to a "better one" or to a "new one", inste=
ad of
starting to maintain two of them from now on with no plan, don't you think =
so?

> And no, it doesn't fix the sysfs problem because the=20
> sysfs stuff isn't removed.


Yeah, I had the same in mind, that's why I was asking for the purpose of th=
is.


Cheers,


--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--pFej7zHSL6C5fFIz
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJQugXiAAoJEADl0hg6qKeO6iMQALALBgFLW3f6uF8P4IWmx3dQ
dSko9VHkHq4aceK5kj2U73T0WrPUdfWlRibth0xMOY9Z0XhugqdkPBaTG5huacca
ZeJFXI7zpnCt39vd/HpjMgwaDxYJvJKl2rldGWgmiwtFLVHglaVVFdALqcwKCYEw
Hfm49asMp9mcsUCVNO/rUrmPAWeGkngk5On5WtH/bh4FDNm9+sFcrYAZ08C334wM
Rlgkxgx9eb1TtsqNBqyxyotgb5paHfcarb861n3iVH568WGyLOPtIsQHVA3ftXcW
XUCuOWIONRT1bF/UfJT6mCvj4Vq6Qwcl94x4+r1/AyYNR7LyVr+I+MzplgY6bM3G
sUtd3teMWRugaegX0S3Y1qhiLIMWQFxCJYPaafmJ+eRcy9/yFLlLEyimtOo9HJoU
g55xU2c3ghoNL7gHJXWflmt27GW9zNYFWqJ/NwB2NhG+9LIoNuYywL/iJUihNOlb
tSAq3Lv06npitKahuKsF0xsjuDBeNuINewNZLIx6ylOotNUqrKuafiKbJMjAbd8e
dsIYHWKkYY45gbKJQ+VnojKraiiToMvlp3xwlqpL5fVkTiDfYWDJpw9C1X46mbHy
Qp+0f8LsNhSmeEb0a0akW6I0p9W9R5Zt6xOeubBsElfubO5a51lR6+RrP6lRW8B+
iJK5jvW9dEIrQrHwRD26
=7fEk
-----END PGP SIGNATURE-----

--pFej7zHSL6C5fFIz--
