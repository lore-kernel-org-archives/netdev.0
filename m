From: Harald Welte <laforge@gnumonks.org>
Subject: Re: (usagi-users 03222) Re: support of IPv6 by NFS
Date: Sun, 6 Mar 2005 12:04:42 +0100
Message-ID: <20050306110442.GW30487@sunbeam.de.gnumonks.org>
References: <42243F8D.5030302@bull.net> <200503010744.38339.Info@Quantum-Sci.com> <1109689712.17484.6.camel@firenze.zurich.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4SRTEifjNkXp0Rce"
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com
To: Jeroen Massar <jeroen@unfix.org>
Content-Disposition: inline
In-Reply-To: <1109689712.17484.6.camel@firenze.zurich.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4SRTEifjNkXp0Rce
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 01, 2005 at 04:08:32PM +0100, Jeroen Massar wrote:
> >My experience is that IPV6 is extremely difficult to figure out how
> >to set up securely, for the time being, due to lack of
> >connection-sharing.
>=20
> NAT is not a firewall. Get that into your brain.

oh, that was what he meant.  I wasn't familiar with the term 'connection
sharing'. =20

I've stated numerous time that IPv6<->IPv6 NAT will only end up in
netfilter/iptables over my dead body.  IPv4<->IPv6 NAT-PT is a different
issue, obviously.

btw, the IETF BEHAVE group is actually demanding that a NAT device does
not NAT ipv6 traffic!!

> And indeed there is no Linux firewalling code yet, in the mainstream
> that can do connection tracking.=20

still, ip6_conntrack is shipped by commercial distributions like SuSE...

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--4SRTEifjNkXp0Rce
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFCKuPKXaXGVTD0i/8RAkXpAKCVDXCOwmaEXub7uAgGPhlIWkdrnQCfUj+A
Cc7FKaz+Qj06mRT1hWs/mD0=
=J3xa
-----END PGP SIGNATURE-----

--4SRTEifjNkXp0Rce--
