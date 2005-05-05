From: Harald Welte <laforge@netfilter.org>
Subject: Re: Help getting Neighbour table overflow a lot messages
Date: Thu, 5 May 2005 13:22:33 +0200
Message-ID: <20050505112233.GT30482@sunbeam.de.gnumonks.org>
References: <20050422103749.43324.qmail@web41403.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7+7T3ZdO12I8zLgo"
Cc: net dev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: cranium2003 <cranium2003@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20050422103749.43324.qmail@web41403.mail.yahoo.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--7+7T3ZdO12I8zLgo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 22, 2005 at 03:37:48AM -0700, cranium2003 wrote:
>           inet addr:10.1.1.30  Bcast:10.255.255.255=20

so you have a /8 on your network interface?  looks like a broken network
setup to me. do you really have up to 16 million machine in one segment?

Anyway, with this network setup you need to make sure that your linux
box has got enough memory for accomodating up to 16 million neighbour
table entries, and set the respective limits high enough so it can use
all that memory...
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--7+7T3ZdO12I8zLgo
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)

iD8DBQFCegH5XaXGVTD0i/8RAut/AJ4tELmFou72ZY6Vv4jA2xVL6pwkCwCggmth
h9S5izQGR0DlN6Wm+eFEnk4=
=EdSx
-----END PGP SIGNATURE-----

--7+7T3ZdO12I8zLgo--
