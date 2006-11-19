From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 10/13] bcm43xx: update to new d80211 driver API
Date: Sun, 19 Nov 2006 20:52:19 +0100
Message-ID: <1163965939.9216.2.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
	 <1163964661.15473.59.camel@johannes.berg> <200611192043.11122.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-1ZlF5jPtoACuPxjtii8d"
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Ivo van Doorn <ivdoorn@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:16071 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933112AbWKSTyb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:54:31 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200611192043.11122.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-1ZlF5jPtoACuPxjtii8d
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2006-11-19 at 20:43 +0100, Michael Buesch wrote:
> On Sunday 19 November 2006 20:31, Johannes Berg wrote:
>=20
> > --- wireless-dev.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debug=
fs.c	2006-11-19 20:12:47.629275208 +0100
> > +++ wireless-dev/drivers/net/wireless/d80211/bcm43xx/bcm43xx_debugfs.c	=
2006-11-19 20:14:01.189275208 +0100
> > @@ -285,7 +285,7 @@ void bcm43xx_debugfs_add_device(struct b
> >  {
> >  	struct bcm43xx_dfsentry *e;
> >  	struct bcm43xx_txstatus_log *log;
> > -	char devdir[IFNAMSIZ];
> > +	char devdir[16];
>=20
> What's the purpose of this?

Well since there's no interface name printed into that string any more
but the wiphy%d I figured I'd not use IFNAMSIZ.

johannes

--=-1ZlF5jPtoACuPxjtii8d
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBFYLXz/ETPhpq3jKURAvY0AJ0fFgputYkbG4rIbSbHrBTXgmAOBACguo0H
Yjqj3HmnHzFFbjlXAfMzot8=
=Vtdi
-----END PGP SIGNATURE-----

--=-1ZlF5jPtoACuPxjtii8d--

