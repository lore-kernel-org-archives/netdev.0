From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/17] d80211: fix monitor interfaces
Date: Fri, 21 Apr 2006 23:01:28 +0200
Message-ID: <1145653288.3897.49.camel@localhost>
References: <20060421201147.D4F76482CF@silver.suse.cz>
	 <1145651369.3897.33.camel@localhost>
	 <20060421224935.5acd79bf@griffin.suse.cz>
	 <1145652778.3897.43.camel@localhost>
	 <20060421225729.34dae18b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-gDcQCotln3o1Pzsfs0Ui"
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:32713 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932474AbWDUVBc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 17:01:32 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060421225729.34dae18b@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-gDcQCotln3o1Pzsfs0Ui
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-04-21 at 22:57 +0200, Jiri Benc wrote:
> On Fri, 21 Apr 2006 22:52:58 +0200, Johannes Berg wrote:
> > > and this will work - independently of the value of monitor_during_ope=
r.
> > > The difference is that in case of monitor_during_oper =3D=3D 0, you w=
on't
> > > probably receive much more frames from mon0 than from sta0. But - you
> > > will most likely receive beacons on mon0 and also monitoring headers
> > > (prism2 headers presently).
> >=20
> > This I don't understand, doesn't the UI kind of suck as opposed to just
> > putting the sta0 device into promisc mode?
>=20
> In promisc mode, you receive only packets destined to your BSS,
> regardless of their source or destination address (so it's similar to
> the way promisc works with Ethernet). On monitor interface, you receive
> all packets regardless of BSSID.

Yes, but didn't you just say that when monitor_during_oper =3D=3D 0 then
it's equivalent to promisc mode?

johannes

--=-gDcQCotln3o1Pzsfs0Ui
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIVAwUARElIJ6Vg1VMiehFYAQK2ig//VtaVKjcf9X8Zlf11HKyZ5RKji23k0o/j
8BFOcd35T8mMmTNC3rs62KrRgnmZZV1LKhodX0EllBOIhSII7SIC++bHEoDcBAum
nRRozWk5h71X6l5MP+aSxAFKNgUY2+CsLbeB0oB5Vwm7B5JXBPA2xz+vCEGbGe6M
6rYW2ff8dvxICEwGqDm192TDXTwPCJwI/DL9RqVjdb1xNGSMLsh4EUyLRsWaKIwX
Ms2bo/ylqN0ktVp8+2pig32Xq8+w2i64ToEZF2uqsYX/D/+UREtpW21O+KRGqaqx
uOGvxDrjiGwRhPU81vEMsSP0OhXnUd7yV4SrzkgLvVHXHweQnDB1CLWNs9u0r0bL
YBXe0knB73gY85KwM0V0kcaNYLa/0TyxsF/9257szIf0eZl8oSHLLl8oT8caCR8X
l0oxGzipxsyuu1dbY1EsYavGlfHP+BbGxdEBuMIZJERT9cJzjn1gNNie09yovHMi
vpgyyzrLv4wiDn1rSkU10F6u7SzuzAZL1OICwE2P1gpA2uYoWxpujowu/ZQtHBp6
b6R1fWvICTuzgXmzq49nZJBFyquqmsRgAnckqy9CSukq12peWGdA+/godk3Yd0+j
BYyqM9rGBKDs+Hm2H/4KURcRns6vCgupYjynHoF7Xkdi4pgQrBxD18tWjF5hJZ/t
7EgXXbULSC0=
=zCI9
-----END PGP SIGNATURE-----

--=-gDcQCotln3o1Pzsfs0Ui--

