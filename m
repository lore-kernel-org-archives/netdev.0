From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] fm10k: fix memory leak
Date: Wed, 18 Nov 2015 12:47:59 -0800
Message-ID: <1447879679.3034.21.camel@intel.com>
References: <20151117142427.37a4cc36@samsung9>
	 <20151118.150612.1789333569072309866.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/ytERyDhZnZXgqc3d/oB"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757001AbbKRUsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 15:48:07 -0500
In-Reply-To: <20151118.150612.1789333569072309866.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/ytERyDhZnZXgqc3d/oB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-11-18 at 15:06 -0500, David Miller wrote:
> From: Stephen Hemminger <shemming@brocade.com>
> Date: Tue, 17 Nov 2015 14:24:27 -0800
>=20
> > This was detected by Coverity.
> > The function skb_cow_head leaves skb alone on failure, so caller
> > needs
> > to free.
> >=20
> > Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>=20
> Applied.

Thanks, got slammed with emails and this got overlooked.
--=-/ytERyDhZnZXgqc3d/oB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWTOP/AAoJEOVv75VaS+3OwzsP/jhwrObaFG22zLNuXKwglHNU
5gYouHm3UcXNYQl9DcDhWkNjxx1ZwFFJ8szRJI9tKcZEc2o9bY7FWmLW9Yt7lgwz
SCBQmdhUfiE3TqRLHEDL/rM5OtYi+ufRWa5GXaQb6vslfqhuXh+AmcUmZ4WO/md+
BoCM40P8G2q2emmLl4jawj+84wGkIOoxGcKuCSpK9LrsDMMb6muuKz6TjbAVQ3Ns
n58o3qsMQSd/UJN5GKZ0TeJ0Vhqp0LYjH/XykDdOUS1VZj73kO031ASMJIztwtC6
F4qeuucfn0gIahi7yp5mzZmsP4UCdEMSGGBxWbhIXOuI0Mwxlg5CkH59ws7BAOt2
tOnF9rQs92BP8jp2b+BaXzTfaYDzGmUJk5Bw0iecqXe7GnjrAMmhpFOwGYo7tUIG
rfz9o+oHK4+zNdrKhQG9Ix4sQ/RwlC5MwDXdNqi3nseEZl2mgGT47BQvaHO0nuGu
+2mR4Y7UB66Du7qIflNIlVqJVNgHn/HaMbUv6uuGKueR4A9S3e22BIVqGpa5mZKT
GgU+mY98EK5x7sQSraQkQp+nBd8EIKg6F5kouPLXW57eV3iYRIDPhcPLKN9XvYsl
bcUUaNT8x1iq13Pi6LT2TkXxwfYaXi2rrwL3efO3k96Qpqn7f7xDj4zJMkUJVlsH
7UaC7yY+qW9PeW1LPWIF
=4QY1
-----END PGP SIGNATURE-----

--=-/ytERyDhZnZXgqc3d/oB--
