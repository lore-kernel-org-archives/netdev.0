From: Harald Welte <laforge@gnumonks.org>
Subject: [BUG] sundance "Something Wicked happened!" (IntrPCIErr)
Date: Mon, 31 Jan 2005 17:59:48 +0100
Message-ID: <20050131165947.GJ6878@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sl5MdczEF/OU2Miu"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--sl5MdczEF/OU2Miu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

I have one machine with 8 sundance interfaces.  The machine spits tons
(16G Logfile in a couple of hours) of the Error message "Something Wicked
happened!":

2005:01:26-17:25:02 (none) kernel: eth5: Something Wicked happened! 0003.
2005:01:26-17:25:02 (none) kernel: eth5: Something Wicked happened! 0007.
2005:01:26-17:25:02 (none) kernel: eth5: Something Wicked happened! 0003.
2005:01:26-17:25:02 (none) kernel: eth5: Something Wicked happened! 0003.
2005:01:26-17:25:02 (none) kernel: eth5: Something Wicked happened! 0013.  =
                    =20
The system is a DELL PowerEdge 1850 Dual Xeon 2.8GHz with two DFE-580TX
fourport Ethernet cards.

Looking at the source code, the error message only happens if IntrPCIErr
is set. =20

What kind of PCI Error is this status bit referring to? =20
Does anyone have the sundance specs and could help me out? =20
Do you think it's good indication that hardware is broken?

Also, the source contains a comment about resetting DMA, which isn't
actually implemented.

Any ideas?

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--sl5MdczEF/OU2Miu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFB/mQDXaXGVTD0i/8RAqLBAJ44KdG1UeDevTpCLESmjhAk4Djr/wCgicni
+2y1E0wbZOzfhVut+ucXlWI=
=NGH5
-----END PGP SIGNATURE-----

--sl5MdczEF/OU2Miu--
