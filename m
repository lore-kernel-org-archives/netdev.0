From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 09:01:36 +0100
Message-ID: <1225008096.3478.3.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-G8seWkAIyIwWlDYEmqBo"
Cc: netdev <netdev@vger.kernel.org>
To: Sven Anders <anders@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43915 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbYJZIBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 04:01:42 -0400
In-Reply-To: <49035AF0.6040700@anduras.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-G8seWkAIyIwWlDYEmqBo
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2008-10-25 at 19:44 +0200, Sven Anders wrote:
> Johannes Berg schrieb:
> > This adds a new printf format specifier for the kernel, %pM,
> > to be used to print out MAC addresses. This has advantages
> > over the current print_mac scheme:
> >  * no need for DECLARE_MAC_BUF
> >  * can be used safely in statements that might be compiled
> >    out without the print_mac call staying.
>=20
> Nice, have you though of something similar for IPv4 and IPv6
> adresses?

Not really, are they printed often? I haven't had to touch much code
that printed IP addresses. Nor have I seen them in logs a lot.

johannes

--=-G8seWkAIyIwWlDYEmqBo
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBCPdAAoJEKVg1VMiehFYICYP/RiVpKS0V2iXj5c1S+JgrNcu
y5RAyyep6KUD1soq7l7AhcOYEtdd54KX5rbJHmbvc0q5L/XYMVmyOuv0jArV52fz
vq04E3wiQSDoUSbZiffuxhxtND9UBW3jVJh0s8GCS/mwmY+unlAD7dDxmcJh1l6N
UAp6w8EihnYuA7nUrAXkUOLpilTp4QizeXzmKP4GOlecmF3mFk3NG/GLi64dshaY
ZjpmAAlq8QjgH+gQqlQTysx0FOgAp0+5YQ/UV55Sd1GGWHqxz7xfslRo2smrs8Kz
bELXN1e+pVHA3yTc94LwYYoU4I9gmCi2cjbtkxctJKJcFGK6z8PZt/Vm7cMLJ/DX
gKKlhU3YgW3igG3cdRO+ygzlHBdhlnHBZhVoDPq+pxgr1sZKHQXFsA2BrhPXXShs
5NN9oV6AmQcoSK7CZNNHWN4NiCDjFfQ/HcWSi4IFAfKfWWjsRJPVbVvCOVL24KUa
pkD6ERqaQs6utHVY91flnnv+u39DSGXFyRaYJYnc3vSOoTRPUe6v1CydzVhtiv2D
DMBAJH7HY/VlHBsc2ZZ2qnFBZTixxSZC0jfXBDVc7BoKpdovrbC2GkyX6Z72koeF
a9rGZROrKQN4ON7ODXz4Uavl3TRJK/prHjkISzloawOXQNDmIf8zryCpCDbeT2OK
YG9YzgFfGAaIepB1lS6m
=gfa3
-----END PGP SIGNATURE-----

--=-G8seWkAIyIwWlDYEmqBo--

