From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
	else")
Date: Tue, 31 Aug 2004 14:31:05 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040831123105.GF5824@sunbeam.de.gnumonks.org>
References: <20040830201957.GY5824@sunbeam.de.gnumonks.org>
	<20040830140729.7309ecc0.davem@davemloft.net>
	<20040831013841.GA5824@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0408311145580.12063@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="VeECpbAlTmkAjas0"
Cc: netdev@oss.sgi.com, rusty@rustcorp.com.au,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0408311145580.12063@filer.marasystems.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--VeECpbAlTmkAjas0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 31, 2004 at 12:24:34PM +0200, Henrik Nordstrom wrote:
=20
> >and it apparently happens in a lot of 'typical' setups where you have a
>=20
> Should only happen if the routing is screwed up, in principle..

yes, but it happens to happen more often, thus I see it as a bug.

> >Also, the MASQUERADE lookup (obviously) has no more saddr in the lookup,
> >that's another difference from the 'original' lookup.
>=20
> This is a possible reason why it screws up for such many people? By not=
=20
> including the source IP you make the route lookup for determining the=20
> MASQUERADE information very different from the route lookup when=20
> forwardning the packet.

Yes, since it now looks to the routing code as if you wanted to find out
a source ip for locally-originated packets.

> I think it would for most make more sense that the source IP assignment i=
s=20
> based on routing using the original source address as key.

Question is: can we do this?  Can we ask the routing code to choose a
source address while we already specify one?  I don't think so.

> >That is the presumption I am about to challenge.  Is the 'original'
> >interface really the one we want in this case?
>=20
> If there is policy routing saying that packets with a given source=20
> should go out another interface my opinion is that they should.

Ok, I think I agree with you. It sounds like the right thing to do,
rather than trying to fix a broken configuration within MASQUERADE.

> Regards
> Henrik

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--VeECpbAlTmkAjas0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBNG+JXaXGVTD0i/8RAsN1AJ0amLm3Im3GZ1vIH8SDVcCurjNB+gCfd2+S
XbIY1mTvC8eld/zjcOuInNc=
=h+z5
-----END PGP SIGNATURE-----

--VeECpbAlTmkAjas0--
