From: Harald Welte <laforge@netfilter.org>
Subject: Re: RFC: promote netfilter MARK value from IPv6 packets to sit packets
Date: Sun, 23 Feb 2003 20:33:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223193339.GD15385@sunbeam.de.gnumonks.org>
References: <20030217145727.GA3413@hensema.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HWvPVVuAAfuRc6SZ"
Cc: netdev@oss.sgi.com,
   Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Erik Hensema <erik@hensema.net>
Content-Disposition: inline
In-Reply-To: <20030217145727.GA3413@hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--HWvPVVuAAfuRc6SZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 17, 2003 at 03:57:27PM +0100, Erik Hensema wrote:

> In order to be able to provide QoS on tunneled IPv6 connections, I've
> created a simple patch (definately not ready for inclusion in the kernel,
> since it surely needs a configuration option) which promotes the netfilter
> MARK value from the IPv6 packets to the sit packets.
> Now I can mark packets using ip6tables, and on the ipv4 level I can still
> differentiate between the priorities. Problem solved, I'm happy ;-)

I like this patch.  I think we should make it a kernel configuration
option, but for all kind of tunnel interfaces.  Something like
'propagate NFMARK while tunneling' (or maybe 'preserve' instead of
'propagate' is better language?)

DaveM: Would this be acceptable?

> Erik Hensema (erik@hensema.net)

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--HWvPVVuAAfuRc6SZ
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE+WSITXaXGVTD0i/8RApb+AKCt4eyvqKsmQmXWic+xzOQvyHlJ3ACeOPeQ
3Nb7Q43Lp+sURhPJT7mQR/0=
=a+Jm
-----END PGP SIGNATURE-----

--HWvPVVuAAfuRc6SZ--
