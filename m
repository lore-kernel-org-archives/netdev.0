From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Prism54 wpa update
Date: Tue, 29 Jun 2004 15:21:01 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040629192101.GB14482@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0116543475=="
Cc: prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Netdev <netdev@oss.sgi.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0116543475==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Content-Disposition: inline


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


I'll keep my latest wpa work/patch at the following URL:

http://prism54.org/~mcgrof/prism54-wpa.diff

I've nuked module params and am relying on private ioctls now since,

* we already have a [s|g]et_wpa priv iotcl, and
* in preperation for the WPA patch for Wireless Extensions.

I'll work on wpa ie scans tonight and try to fix mgt for
handling traps in extended mode. This is not related to wpa, but
I also made the firmware load at probe time. I turned the radio
off at probe after firmware load time too since the device is
not technically up yet.

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA4cEdat1JN+IKUl4RAr7HAKCWl78xE45gcKcWFUJo0QCLQb2RoACfYOz3
Uy06CXuRohax/OYfmDrJmwE=
=dDHU
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--

--===============0116543475==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0116543475==--
