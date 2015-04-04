From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Configuring synchronous ethernet with ethtool?
Date: Sat, 04 Apr 2015 14:59:10 +0100
Message-ID: <1428155950.11260.66.camel@decadent.org.uk>
References: <20150317161128.GA8793@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BVmsy44AGEOkdXhO8dtU"
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57736 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752668AbbDDN7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 09:59:22 -0400
In-Reply-To: <20150317161128.GA8793@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BVmsy44AGEOkdXhO8dtU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-03-17 at 17:11 +0100, Richard Cochran wrote:
> Dear list,
>=20
> I need to configure Synchronous Ethernet (SyncE) on a per-port basis
> for a current project.  So, I have been thinking about how best to
> implement SyncE.  My first idea is to make this into a new ethtool
> operation, but I would like to get some feedback about the direction.
[...]
> So, my current idea is to have an ethtool option to set the SyncE mode
> to one of:
>=20
> - master (1000 Mbit only)
> - slave
> - none
>=20
> I am not sure whether the manual/preferred thing makes any sense.
> Maybe someone has insight into this?

The 'manual' setting matches terminology in IEEE 802.3 (section 40.5.2).
There's no mention of 'preferred' there but perhaps this switch will
claim to be a single-port if you say it should prefer slave mode.

As you know, 1000BASE-T also uses synchronous TX clocks; so does
10GBASE-T.  It might be useful to be able to set the flag for multiport
device on Linux systems with multiple ports connected by a software
bridge.  Both this and the manual settings could be useful for link
compatibility testing.

So, I like the idea but it should not be tied to SyncE only.

Ben.

--=20
Ben Hutchings
The most exhausting thing in life is being insincere. - Anne Morrow Lindber=
g

--=-BVmsy44AGEOkdXhO8dtU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVR/uM+e/yOyVhhEJAQpsVxAArknJutkSkvurxZe4ld0uZYV8m5Rk0LgJ
7UC5W7fET2bjloML2oooJzcnWLJi7xO7nHqq89GJL0ubcDtSCZScQSOWuO+i7p3d
fFgv1VHixmd+/SJbggxEaxH98E6a362MHFHCaWSxgPIW066aSceyXnGs1SR/h19b
gOBntOfoHoZmqspObeQGtG0LUEQpJYitXbHn1++SYwE6K9K/sn19Yy7pfLSpp2nS
fvFQ5Gr9qubrkCJ2+yQqnj0QN4NiV2AHRogAj7V/wp8DgKUWTOpQUlGemb0h2WX7
enhyRG2+YbNsAShJtlIwCF2lBlsCzqhTjXU381DIYCD3e7CROIffn2v4EXqivztW
mZPPNPXKWiHUJN2/1pca4WbCA9+cbI6dGvbCu2UuXs7bOS1CYiO3FLd3/zJj4ykd
PFysJcbM3efS7p90G0MV6eK0QPUjQAswyZ5xJgyjxX+J//3us0XqZDd3FyHV5pyR
EdoZT5+dolnCtPkxmdiSpxGmbrczNnGzkpwENKdWzyklizrocSzL718ppB6dERDG
O58DnyLkkytaz4wBcgPGtt/NpmZYHIgZFElTMUT1qjgrlicrY1rK/kPY3CQvjlzg
yojNcea15T1YpEzRYmNQ3hjNAvzJdcU7GXzMbmXQ4MdukctaT6rDXhP+xiD2Gdm1
s81t7SIJtSY=
=1xGY
-----END PGP SIGNATURE-----

--=-BVmsy44AGEOkdXhO8dtU--
