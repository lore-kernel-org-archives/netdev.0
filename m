From: Ben Hutchings <ben@decadent.org.uk>
Subject: e1000e fixes
Date: Sat, 23 May 2015 18:08:34 +0100
Message-ID: <1432400914.12412.88.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rk3UbV7hIG/h1ehkrwj5"
Cc: stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: e1000-devel@lists.sourceforge.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rk3UbV7hIG/h1ehkrwj5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

I was looking through recent changes in e1000e, and thought these might
be suitable for inclusion in stable updates:

commit 493004d04f56fd7d642bdbb2938e17e5f7d622d1
Author: David Ertman <david.m.ertman@intel.com>
Date:   Fri Jul 4 01:44:32 2014 +0000

    e1000e: Fix CRC errors with jumbo traffic

commit 47ccd1edc57ddabb81f6ba07e1e30201a8f578d6
Author: Vlad Yasevich <vyasevich@gmail.com>
Date:   Mon Aug 25 10:34:48 2014 -0400

    e1000e: Fix TSO with non-accelerated vlans

commit 6930895df994af212985396f1274712aaaa5bc26
Author: Mathias Koehrer <mathias.koehrer@etas.com>
Date:   Thu Aug 7 18:51:53 2014 +0000

    e1000e: Fix 82572EI that has no hardware timestamp support

This is purely based on the commit messages, not on bug reports or my
own experience of the bugs.  I leave it to the e1000e maintainers to
judge whether they're important enough.

Ben.

--=20
Ben Hutchings
If more than one person is responsible for a bug, no one is at fault.

--=-rk3UbV7hIG/h1ehkrwj5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWC0F+e/yOyVhhEJAQpRwBAAsJwxRErhpif9Ua5u5HKEFh3E+tIiPwmh
AOjP8KXYEH8iLyQx/V20gdDZmmaptw2dhIXhUXpoA9zG7KaHx1molZiFAkq8KpuK
G8QU9SHKMC9jk1ZSMzvb76h87tLbp/s8Saagg6lqbQUJE+llNDfEh5Sb+S8iHljl
45+1vo6ecPprg4DQ58jX3CGI0HLm/Yks3hl/GMAcT5zw9xBQCodq8dQ/frx5Mhml
/RgnzxU5QYfNvAE/kHI4AHSXl0wHYoh5IJZOhyTK6eCcZE+NN77ToXOUHcYdITDl
XOGvciNgYXyQBsaQFimFZMastrsE49/Scm8YRD4K5FujITMYx7SmhfYwTO5nyvID
5Us0/uNcuT+F9DfIusNge3oETJ8fskL5er3fbYZWgE6IcK6zwZl3ZpU7lLp8HL/K
Pspj8KxU8I1oP1EOdf1oumwyOo8Mif+s+IkYw7Avbpy3KJolnajpSskIxagEBIRq
jEKNTmaaGsVAGlXsw2mRT04K/4i9i6uAKwizVFflKr0HoB/2aaHdDhqAcheqoqeg
QlV6l/zH2w3VQjHubnZcoG8tvjpg3zmDalTGQV5AQDHG6tDZtg1DRNQnWGeQQa+k
bLcJFkoOF0aOghlepvx+xTDa1l4rm4OTUPklOZpI1jBw6pLnQMPRhhz72skZP762
6Q0k5M9F8r0=
=esoI
-----END PGP SIGNATURE-----

--=-rk3UbV7hIG/h1ehkrwj5--
