From: Harald Welte <laforge@netfilter.org>
Subject: IPv6 multicast (MLD,IGMP) code bypasses netfilter hooks
Date: Sat, 22 Nov 2003 10:03:30 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20031122090330.GB2745@obroa-skai.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gj572EiMnwbLXET9"
Cc: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--gj572EiMnwbLXET9
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

At least to me it was not known (until very recently) that the IPv6
multicast code in net/ipv6/mcast.c bypasses the netfilter hooks - but it
does.

I don't have the time to work on this right now, just wanted to drop a
note to netdev that people are aware of this issue.

This basically means that you cannot do packet filtering with ip6tables
on outgoing MLD packets.

If anyone wants to write a patch before I get the time:  Feel free to do
so.

Dave: I think this would be post 2.6.0 stuff, wouldn't it?

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--gj572EiMnwbLXET9
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/vyZhXaXGVTD0i/8RAhXMAJ9HwavVXbQRWHJKDypYudZuQREYjQCgkPUW
G76+cbhcjLfrabhJ54YTMLY=
=M8kW
-----END PGP SIGNATURE-----

--gj572EiMnwbLXET9--
