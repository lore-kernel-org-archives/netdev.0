From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: dmfe/tulip device id overlap
Date: Wed, 25 Nov 2009 13:08:22 +0000
Message-ID: <1259154502.16258.36.camel@localhost>
References: <20091125043603.GK14043@jenkins.home.ifup.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-qjy4pHl1BKjcT2+6m+4/"
Cc: netdev@vger.kernel.org, Tobias Ringstrom <tori@unhappy.mine.nu>,
	Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>, davem@davemloft.net
To: Brandon Philips <brandon@ifup.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53224 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934212AbZKYNIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 08:08:22 -0500
In-Reply-To: <20091125043603.GK14043@jenkins.home.ifup.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-qjy4pHl1BKjcT2+6m+4/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-11-24 at 20:36 -0800, Brandon Philips wrote:
> Hello All-
>=20
> dmfe and tulip have an overlap of device IDs and it has been discussed
> before without resolution[1][2].
>=20
> The device ID in particular is:
>=20
> 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
> 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
>=20
> Users of Fedora[3] and openSUSE[4] are feeling pain from this but
> Ubuntu users are avoiding the issue do to the patch below.
[...]

Also an open bug in Debian (#515533).  Thanks for pushing this issue.

Ben.

--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-qjy4pHl1BKjcT2+6m+4/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASw0sQee/yOyVhhEJAQISGg/9F++YP9UTcFYE9g6yrgAghOv90Jw9NWot
jXpi55evGwxFN4MNzDyWPAXBn6cXH1bpXyAtK//qnIwLcrSQIa+5xcUdA5PS7QRM
WMN4vl3epnH4KjoY4d9ehzwLYqPyzAOO+4s9rgTMsajQAUe57DJuHyE0FlgnNINp
ouGK0hkIis/pA8wvYirGZ8P/sY1yMPSRZnBbfzUZVfrwDX3TKuBK4jBu42C0WgTc
hiOKRyxQi88aeB/h+ItIFsZU9+npMGOcQRceM3zmGVycrRwwlLxZWV501L2Uj+en
tnJFOW/q+DItMWoTlaAZezQzRZo+MWUxcuH65+BcpFxIo+3Sy4dH3W0V4x1bsFQn
yFAzRxN8Q52Ih1iLRbYxJCMjj9YcMhAx0+rOzIk+KS0YAn23w+/MLeg8P+jfCPZP
gYU29vGMUa7OW4cih7K/R7Ro2N8jGOo4I6STv5XspavsrTR9dkXBnEp1Ii36FDwG
XxZnmBvMDzVJw6yyjtXJJe8V2pp57tNE5sjWTMKS0gEGSz1nhER3ZhSzd5BevLFQ
A61hgd9qQMmc8vs9SSLxkU3Ucbr+Zx6T5wU4AvP+hPBwvyhrVDT718WtICRxpEas
DELH1fyYgKjAQgqblzjwdiYan1tPt8Z0vAo70C4Qm/Zu8sUAdZU1i/MZ6zJ8wH+3
7/HgdU+aFYw=
=VErS
-----END PGP SIGNATURE-----

--=-qjy4pHl1BKjcT2+6m+4/--
