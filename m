From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: fix regression caused by regulatory config
	option
Date: Sun, 26 Oct 2008 21:22:16 +0100
Message-ID: <1225052537.3746.5.camel@johannes.berg>
References: <20081026103024.2712ddc9@infradead.org>
	 <20081026200939.GC12648@tuxdriver.com>
	 <20081026131818.7517c103@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-o9E+oGLcfqVPTJlPMJSw"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, rodriguez@atheros.com
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52297 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbYJZUW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 16:22:56 -0400
In-Reply-To: <20081026131818.7517c103@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o9E+oGLcfqVPTJlPMJSw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 13:18 -0700, Arjan van de Ven wrote:

> > Is it common practice to have compatibility options default to
> > "y"?  I'm not saying it shouldn't be, just wondering if it has been
> > traditionally?
>=20
> yes
>=20
> default should be "keep working as before"
>=20
> it's not always nice, especially if you're trying to get rid of some
> nasty stuff, but think of it this way: you should be able to use a
> new kernel on an existing distro, at least for a reasonable type of
> distro (eg something shipped in, say, the last 2 years). In this case:
> even Fedora 10 is not likely to work!

Well, actually, it _ought_ to work fine, with a smaller set of channels,
but you seem to be hit an iwlwifi bug that triggers only with this,
which is rather odd.

johannes

--=-o9E+oGLcfqVPTJlPMJSw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBNFzAAoJEKVg1VMiehFYUdMP/R+r/r0lUzFZnVELjJwW653S
AUJQd1zO2pbQ71sk+/KaWBDvw4QgDlydbW+6kcQg3aFnV/IJzMvXHvjoDvz3PtUf
G+3F/Qfns73V4hYI2dhxUm52tVDT9W1HS/UXqVmxtahhljF4TcZn5gv60KWUBdAH
e2jwQVubSipEB9/Wb8WCGRmhKXntA2LCzX3OLiawJZHpl+XRByjw148VIe56jI4G
5hzeRfefvl48oCn0+zVY+RQrWb3k+J2/wGDS48V8zH0cdOSUtz6CHBiNo3qPu+ld
cL05sHC5kBOpe+uWs1K4rYf+MdLlYzHNcgFzNIbXgBgXkX9FtDoksjgdVg/P1xVJ
ln54uSKfYoykgrA9/hwsfboLOXFWWPOD8Xuc33t7yGvgTtbTJZeYUZ3XisKb3CPz
3UEmL/Rkls4oabGgu50p/0okbaaMtHCasUX7cOt2B9yaZgjGbYttIA7+3WntGzCB
XfIHhAkdCX2cb3zrGpfwAuqVyETbM24lWqcaB/zq/VPzPgw+Yz5nKDBgYxSmcfVd
mh1FIRuYDkSmTTfHJQjJhyP+k53hQhzQxRo5K3fqWbeJpQhHideYaUR4i72CJnHp
p+XgZTLnQt1fbc1LKuPaN//7YKI10B4uwjJSyPeRRrJd709qh3B/b2Rd887bIDKJ
e27CxCsicXXG0djqc8S3
=Th9c
-----END PGP SIGNATURE-----

--=-o9E+oGLcfqVPTJlPMJSw--

