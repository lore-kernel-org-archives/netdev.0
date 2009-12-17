From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] bonding: cancel_delayed_work() ->
 cancel_delayed_work_sync()
Date: Thu, 17 Dec 2009 15:30:59 +0100
Message-ID: <1261060259.10356.112.camel@johannes.local>
References: <20091217002808.E44D0254177@hockey.mtv.corp.google.com>
	 <20091217074930.GA6779@ff.dom.local>  <20091217133644.GD8654@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-+rghXHjc28D2eEExKknC"
Cc: Mikhail Markine <markine@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Petri Gynther <pgynther@google.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:58106 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764807AbZLQObW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 09:31:22 -0500
In-Reply-To: <20091217133644.GD8654@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+rghXHjc28D2eEExKknC
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2009-12-17 at 13:36 +0000, Jarek Poplawski wrote:
> On Thu, Dec 17, 2009 at 02:19:46PM +0100, Johannes Berg wrote:
> > Jarek,
> >=20
> > Sorry to mail you directly, but I only saw your reply on gmane and
> > didn't want to break up the threading etc.
> >=20
> > cancel_delayed_work_sync() should be ok in this case unless the work
> > items themselves used the rtnl,
>=20
> Hmm, I'm not sure I get your point, but e.g. bond_mii_monitor() work
> function can get rtnl_lock().

Ok in that case you can't cancel_sync() it under rtnl. I was thinking of
the case where it's just not ok because of other work. Sorry for the
confusion!

johannes

--=-+rghXHjc28D2eEExKknC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLKkCYAAoJEODzc/N7+QmaGFoP/0n+5YD8fJPy7UeI1sHOWbZ8
nMxYyLwo1XHamWPn44Dj9jKv/L3VpChp0WJB3NNIdFfj/MDWKl7RfBF9FGcdTNis
Eor44DJtlUHfYJRb+27p6WfETH4958InZz7wJrdw8uIeo99zT2DBglSDm9AK95pl
1hwk+JbKvgk2fcq8ng3Q6GYbsFPI9FPJjrcUZeveZ72U3TqtLp60aAmnugI7OCTn
/+wJ1nfd6KMLiJqr0j0yFtHodtm1rCC8fLB61JL7dWJdgLuifvK3jNI5pNRR0LuJ
VS0s8kIVJyLhJGQdX4Tu48MvOcWRVPJabAQpZYC0eqLMi1UygzEA22m93MRVt3kO
w/9iltsGFTPObYr9szIUDb4Bt6sPkr0GQEDuMKIEUKGa74ZiYQ7oFF/5j+UiJTul
CkFu1AWnnAaUYCuMy74oQouX85a/WiO7StAl9MaqBZDBV2ZnBysILhEqp5nxaQn0
8fwJ2GWe6W9gdRCkOImC5AMKBSpwUPv2Do0X6g4a7zNfDFtk1NqHFDtbzEqEZlql
fI2X/rEvj4AsweVhcV0VcGM3L2B6pg64ieaqMX+Bu7Gu6IohSMZv9j9qORQFrAQC
JC/agQ9LPOhBmJq6yilLUXx7ivAmYhln2s7VOetfFZIB523xqhSFRzVG9SABX7FA
yr+pICwqw9Ciov9GdMHe
=1H0P
-----END PGP SIGNATURE-----

--=-+rghXHjc28D2eEExKknC--

