From: Harald Welte <laforge@netfilter.org>
Subject: Possible ip_defrag DoS ?
Date: Sun, 16 Feb 2003 21:11:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030216201154.GA30787@sunbeam.de.gnumonks.org>
References: <20030215232635.25928.78900.Mailman@kashyyyk> <15950.60635.389199.836425@isis.cs3-inc.com> <3E4F0881.70302@trash.net> <15951.10496.914173.716313@isis.cs3-inc.com> <3E4F8660.5020409@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
Cc: Don Cohen <don-netf@isis.cs3-inc.com>, netfilter-devel@lists.netfilter.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <3E4F8660.5020409@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Feb 16, 2003 at 01:38:56PM +0100, Patrick McHardy wrote:

> inerestingly, it seems linux defragmentation is vulnerable to dos attack.
> the evictor (called before defragmentation) just kills the oldest entry
> of each hash slot, starting with 0 until memory is below
> sysctl_ipfrag_low_thresh. by sending enough fragments=20
> (>sysctl_ipfrag_high_thresh) which hash to the highest bucket you can
> stop reassembly of valid packets.

I'm forwarding this (from netfilter-devel) to the linux networking
developers at netdev@oss.sgi.com.  If your assumption is valid, they
might want to have a look at this...

thanks.

> Patrick

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE+T/CKXaXGVTD0i/8RAk0YAKCHcxU3Z8IVQlfniFRJ46wDL+aKRACfaNf1
xUsNuY9XvXsdzUKesSfqERk=
=2JId
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--
