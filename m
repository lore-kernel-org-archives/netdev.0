From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
Date: Tue, 22 Oct 2013 12:11:27 +0200
Message-ID: <20131022101127.GJ1544@neomailbox.net>
References: <20131022.025038.1046903740187748879.davem@davemloft.net>
 <1382431715-3128-1-git-send-email-antonio@meshcoding.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="u3bvv0EcKsvvYeex"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:32116 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab3JVKMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 06:12:08 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B739B@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--u3bvv0EcKsvvYeex
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 22, 2013 at 10:09:00AM +0100, David Laight wrote:
> > Subject: [PATCH net] netpoll: fix rx_hook() interface by passing the skb
> >=20
> > Right now skb->data is passed to rx_hook() even if the skb
> > has not been linearised and without giving rx_hook() a way
> > to linearise it.
> >=20
> > Change the rx_hook() interface and make it accept the skb
> > as argument. In this way users implementing rx_hook() can
> > perform all the needed operations to properly (and safely)
> > access the skb data.
> ...
> > -	void (*rx_hook)(struct netpoll *, int, char *, int);
> > +	void (*rx_hook)(struct netpoll *np, struct sk_buff *skb, int offset);
>=20
> You can't do that change without changing the way that hooks are register=
ed
> so that any existing modules will fail to register their hooks.

There is no hook registration in the kernel tree. All the users are outside.


--=20
Antonio Quartulli

--u3bvv0EcKsvvYeex
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZk9PAAoJEADl0hg6qKeOOpMP/3QXrvhRi+kTWjyOR4WuytOJ
3z757RR5+LhUJj+gyOyzWjSxtlw9sU3jJ1BvWQrMB0CORC0Ux90kfjaAbB5+vwHg
rTtNEIAs2Te619ZPQGdm5CjPyNn2eV6gjCDyHsRK7rEWilZPqKVHtrRJQXW1+RAK
hVV0TDynFqij5XCYK+gQ8JuRlZdt6E0yReUJr//aG7/Us5mBOn+Fl5R+WOmNP8BS
RAfCzFD4Vb03Tf24EfARM6DazeEcNPBN5WtEz5hP8db0Gd1zeRg3rSQP+U1Jn/X1
MRf6SLxptBBsmtBdRuffR7KWIXcR6loN3zWeiaajCoEbVgrNfjzB9SZWdhFeIfsM
GpEqzyx8wb3MzS2jAJDg34VHFC/jo5GjdVfbxixmk6qgNQieA6pwmk9uUnM2aYUN
LTAq2Jd1XwQ+hmR2bGZQ5Ov8i6wu+FzoXcrMkDk3laN/mqQnMZz/PH2lx/I3/pk7
gWmQRlhnHieMoqCVRN2OUMh8TLxTOpGY4H5he+fHLNoSpWIPGZhFh0Y0NEtd3Fo/
maR1A/2ApTuU93qvqxDDCzViHZOCclplQrtZ6JzE6eNdwOBjjB2qhLMSE9C1HMO+
AVbuRiAlRTG3LlD1Hpxwo8nswbvCbcAeeh5EoclruX7dq+JEace4hanSOGqT3bB5
uAf5uUoo3d0wEz5q+ZXb
=knxL
-----END PGP SIGNATURE-----

--u3bvv0EcKsvvYeex--
