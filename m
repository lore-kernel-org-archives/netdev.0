From: Jason Lunz <lunz@falooley.org>
Subject: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Wed, 10 Jul 2002 18:32:37 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020710223237.GA7995@orr.falooley.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="azLHFNyN32YCQGCU"
Cc: Robert.Olsson@data.slu.se, greearb@candelatech.com,
   garzik@mandrakesoft.com
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


I've backported the most recent napi sources I could find to 2.4.19-rc1.
The patches are available at http://orr.falooley.org/pub/linux/net/.

Testing and suggestions are welcome. Currently backported napi drivers
are e1000, eepro100, tulip, and 3c59x. I intend to backport dl2k and
sundance at some point, but I have no dl2k cards and I'm working with
Donald Becker to get the sundance driver working on the card I have.

Does anyone know of more recent NAPI conversions? Robert Olsson tells me
Jeff Garzik has a more recent tulip conversion, but there are _no_ napi
net drivers in 2.5.25 and I haven't found any others except for those
mentioned at the NAPI ftp site.

Jason

--azLHFNyN32YCQGCU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE9LLYFaDU3zTAC0GcRAiP+AJwOEmMKfXW2fBWFq0r+u7OK636OYQCcC/FT
TAq5A0OiWJ+LSuZEP1DqXLU=
=PlFN
-----END PGP SIGNATURE-----

--azLHFNyN32YCQGCU--
