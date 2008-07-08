From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 08/11] remove CONFIG_KMOD from net
Date: Tue, 08 Jul 2008 20:37:00 +0200
Message-ID: <1215542220.3670.0.camel@johannes.berg>
References: <20080708170015.470877000@sipsolutions.net>
	 <20080708170047.433712000@sipsolutions.net>
	 <20080708183035.GC11954@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-6bh8J+t7EFKgwnP76zvh"
Cc: linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:35298 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbYGHSh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 14:37:56 -0400
In-Reply-To: <20080708183035.GC11954@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6bh8J+t7EFKgwnP76zvh
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-07-08 at 21:30 +0300, Adrian Bunk wrote:
> On Tue, Jul 08, 2008 at 07:00:23PM +0200, Johannes Berg wrote:
> >...
> > --- everything.orig/net/core/dev.c	2008-07-08 18:35:53.000000000 +0200
> > +++ everything/net/core/dev.c	2008-07-08 18:36:06.000000000 +0200
> > @@ -4639,7 +4639,7 @@ EXPORT_SYMBOL(br_fdb_get_hook);
> >  EXPORT_SYMBOL(br_fdb_put_hook);
> >  #endif
> > =20
> > -#ifdef CONFIG_KMOD
> > +#ifdef CONFIG_MODULES
> >  EXPORT_SYMBOL(dev_load);
> >  #endif
> >...
>=20
> You can remove the #ifdef =20

Eh, no. Not unless I also always compile in dev_load, which as of now
depends on CONFIG_MODULES. In fact, another hunk in this series makes it
a static inline when CONFIG_MODULES=3Dn so that callers don't need to take
care of #ifdef'ing it.

johannes

--=-6bh8J+t7EFKgwnP76zvh
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIc7PHAAoJEKVg1VMiehFYYgUP/jH1E5Rj4st4QTOATJvuUO96
gduT79axxT2Mk6Cv6i+4jrTrUbA8yVw9ZAyn/xaX1TIr+13YFJ8vVD/NgJSIJz+b
MBPuTaVtBdDN9J+GUIJibVNwCGvBGOUpaEuh6WouyKLH7Enzrdr1SdiPvSFAWc3b
M8FBIyd8jEBUdsQun1KsEUw+tzCoX5EN35rHZM5CSHa2KjytDqGBhqjoVFIbCJYf
ZocLCn1EajMp1qQDJuNCfa7A1x7kxrEa09BSfu2PyMgORVII2hDGzkLzRTAwF3Wc
LVgOGOQosfg/iuSirY5iez5MM4HIjiAkaJD0weLhTj4KVPRJ8Jd831szeLWi5Qxb
V2sqtQZGeTYKjjHdSqOSj728C/NBdkXo3nVgjwoB0dxOw1F1PB5GNipXQn0K4w0+
7z3Agf74/bQcpaOVVIy96+xXgGNYjwmrGQHdf0166lAPRROt89qzL2HcW7SHfrQE
wX/ij6RxTjyptYIqFoBKXL1kHF3GS85YgjJJ6zNonT28nmeUJPDoPL85CP8Qbt+2
HFrcYquCuawpw6PYH/oMX/xl2s+l98PYUsnij+7aNdi4LJdfQCZON2Sy/bQ6wD4f
1l8ZdYFCsNkWDHfL46AHUuGTdjGMuJ/2JG4c+vKzyUs8LUFH/qPjYn7qgN2a5dPu
LVC5mxKumOFiQ5I8kUTg
=6VLs
-----END PGP SIGNATURE-----

--=-6bh8J+t7EFKgwnP76zvh--

