From: Harald Welte <laforge@gnumonks.org>
Subject: Re: kernel crash with G5 Xserve and sungem driver
Date: Fri, 1 Oct 2004 21:31:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001193153.GN27499@sunbeam.de.gnumonks.org>
References: <415D8768.8080808@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1y1tiN5hVw5cPBDe"
Cc: netdev@oss.sgi.com, linuxppc-dev@ozlabs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
Content-Disposition: inline
In-Reply-To: <415D8768.8080808@nortelnetworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--1y1tiN5hVw5cPBDe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 01, 2004 at 10:35:52AM -0600, Chris Friesen wrote:
>=20
> I have patched 2.6.9-rc2 to run in 32-bit mode on the G5 Xserve.
>=20
> When I compile a kernel with the tigon driver and the sungem driver both=
=20
> built-in, the kernel crashes.  Removing the sungem driver fixes the probl=
em.

Yes, I had that too.  The Problem is that the XServe G5 actually has two
sungem MAC's in the chipset but doesn't use them (and apparently their
interrupt lines are not connected either).  Apple just doesn't put them
in their OF tree, but on the PCI they are visible.

The ethernet chips actually used and connected to the ethernet sockets
on the back side are th3.

Just don't compile (or load) the sungem driver on those boxes.

> Is there a known incompatibility between the sungem driver and the Xserve?

yes.


--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--1y1tiN5hVw5cPBDe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBXbCpXaXGVTD0i/8RApp7AJwKFtyJL91PowHWs4uTO6DnaNrthwCgtU9t
sJl0u37ydJljoTsEsvOrDlU=
=+Ev2
-----END PGP SIGNATURE-----

--1y1tiN5hVw5cPBDe--
