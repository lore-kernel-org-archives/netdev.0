From: Harald Welte <laforge@netfilter.org>
Subject: Re: Memory usage for ip_conntrack
Date: Thu, 24 Jul 2003 18:01:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030724160107.GC10897@naboo>
References: <1058563690.26030.23.camel@tux.rsn.bth.se> <16153.56832.379224.202834@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IpbVkmxF4tDyP/Kb"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carlos Carvalho <carlos@fisica.ufpr.br>
Content-Disposition: inline
In-Reply-To: <16153.56832.379224.202834@fisica.ufpr.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IpbVkmxF4tDyP/Kb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jul 19, 2003 at 09:10:40PM -0300, Carlos Carvalho wrote:
> Martin Josefsson (gandalf@wlug.westbo.se) wrote on 18 July 2003 23:28:
>  >> If I echo 102400 > /proc/sys/net/ipv4/ip_conntrack_max, what is my wo=
rst
>  >> case memory usage?
>  >
>  >Don't do this. This will increase the maximum number of connections it
>  >will track, but not the number of buckets. Which means that it will be
>  >slower due to longer collision-chains. Instead increase the number of
>  >buckets. modprobe ip_conntrack hashsize=3D131072 (or any number here.
>=20
> How can we increase the number of buckets with a monolithic kernel?

For 2.4: by altering the default in the kernel source, sorry.
For 2.5/2.6: there is now a generic way of specifying module parameters
=66rom the boot command line.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--IpbVkmxF4tDyP/Kb
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1 (GNU/Linux)

iD8DBQE/IALBXaXGVTD0i/8RAh2DAJ9qobKhgY2vjygWm/0rcGyOkFFkHACgl//g
AL7lgAvRyJXOnotlqbED8Qw=
=cw1n
-----END PGP SIGNATURE-----

--IpbVkmxF4tDyP/Kb--
