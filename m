From: Matthew Dharm <mdharm-kernel@one-eyed-alien.net>
Subject: e1000 with 82546EB parts on 2.4?
Date: Wed, 16 Jul 2003 09:27:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716092739.C17580@one-eyed-alien.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="jy6Sn24JjFx/iggw"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jy6Sn24JjFx/iggw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I'm working with some hardware that may or may not be completely reliable,
and trying to figure out if something I'm seeing is a 'known issue' or
something strange about my setup (which is entirely possible).

I'm using 2.4.20 with some custom hardware.

What I've got is your basic x86 machine with an Intel 82546EB dual-GigE
controller on a PCI bus.  I load e1000.o, ifconfig, and I'm running.  The
interface is solid as a rock, AFAICT.  I've left it running for days
without any problems.

However, if I ifdown and then ifup the interface, I'm borked.  Based on
tcpdump from another machine, the interface is definately transmitting
packets just fine.  But, it never seems to notice any packets on the
receive side.

Has anyone seen anything like this before?

Matt

--=20
Matthew Dharm                              Home: mdharm-usb@one-eyed-alien.=
net=20
Maintainer, Linux USB Mass Storage Driver

A:  The most ironic oxymoron wins ...
DP: "Microsoft Works"
A:  Uh, okay, you win.
					-- A.J. & Dust Puppy
User Friendly, 1/18/1998

--jy6Sn24JjFx/iggw
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD4DBQE/FXz7IjReC7bSPZARAm3QAJ9FXGauZb+6KBBODke+zBhA/GFf+QCYv+Mh
J95mPS67nP0emQlE47bxVg==
=FxNQ
-----END PGP SIGNATURE-----

--jy6Sn24JjFx/iggw--
