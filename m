From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [2.6 patch] build algorithms into the mac80211 module
Date: Thu, 26 Jun 2008 15:46:15 +0200
Message-ID: <1214487975.20763.46.camel@johannes.berg>
References: <20080622125553.GB22539@cs181133002.pp.htv.fi>
	 <43e72e890806220804i347b942claae7b725231afcce@mail.gmail.com>
	 <1214298259.8967.260.camel@johannes.berg>
	 <20080624124311.GC16021@cs181140183.pp.htv.fi>
	 <20080624211222.GB25892@tuxdriver.com>
	 <20080626103813.GB30359@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-kWi03TUrJsXCx1PGffWH"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:36383 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763476AbYFZNqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 09:46:34 -0400
In-Reply-To: <20080626103813.GB30359@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-kWi03TUrJsXCx1PGffWH
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-06-26 at 13:38 +0300, Adrian Bunk wrote:
> On Tue, Jun 24, 2008 at 05:12:22PM -0400, John W. Linville wrote:
> > On Tue, Jun 24, 2008 at 03:43:14PM +0300, Adrian Bunk wrote:
> >=20
> > > Can we get one of either:
> > > - all selected mac80211 algorithms are built into the mac80211 module=
 or
> >=20
> > This seems fine to me.
> >=20
> > > - all selected mac80211 algorithms (including the default one) are in
> > >   their own modules
> >=20
> > We got here trying to avoid this one in the first place.
>=20
> What about the patch below?

Seems ok to me, especially since we don't have a tunable for the rate
control algorithm nor any other than the iwlwifi ones and this one...

johannes

--=-kWi03TUrJsXCx1PGffWH
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIY52kAAoJEKVg1VMiehFYLbsP/3opCtQ2M5NAvPlUxMJWm/6z
rPU7jVxPICD2yPcavke0UueZEyitMqVIWsXzUjRG1M1TrOMzXa8qYnQrvfGre4rM
0AjmSgdCCxVfmIyNuDMrK/HqEIPdcTNeYceP3VyeUz/NT8axVXPw7I1OyGuSmvmP
H4X+BHtqFN8bmUsSDd1ADUAQ1Dv02MvkhADHceWurnQkdCWosOyeaeEKG0rdW8NG
FrQ8Ip0U8Cow0m5NzVAatcmWtWwJxjl58Ic1Cnsb9gvtYuvGlX1ltK7vBRGsdzUo
BGfjP2HI7/NarAXYJGaWTmGDm8+cOPZlCEldP/+vW/YWm/IBJGnkU37sXZbUTyFI
ur8t8HWamgpkb7kTbKnMh09XBJLyzunzNpFc/6EvxfhRoYR3rqb64f3spwhsxdG0
1zZkpNgwcg3uZxqP+ZKW7QYOirH28D60qD6EnJVxDx6oWv/Hi/lc9XSvjnf+breU
pR7OSy4sNSTx8IDxTRy98OZ+lwrm4oJ+tnneEOOZY2ZYMUw9V3rN5WVa3G+OqLi5
b/hgsMQa+4x52RhjiBXPPvf28sCBJ7iiiYqaAhOva3ep9+khdV2eTQ9CiD1KJ9Jx
lP52pxPX690N4tfIqelVSDh6npr0SwbgDjatWNntUYZYy6Egy4vjtpDQxv1OmR1d
uhxDlfeDCPHeISM5GSRm
=473j
-----END PGP SIGNATURE-----

--=-kWi03TUrJsXCx1PGffWH--

