From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH 2.6] iptables CONNMARK match+target
Date: Thu, 21 Oct 2004 11:16:32 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20041021091632.GB3551@sunbeam.de.gnumonks.org>
References: <20041020222102.GO19899@sunbeam.de.gnumonks.org>
	<Pine.LNX.4.61.0410210912280.18310@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MW5yreqqjyrRcusr"
Cc: Linux Netdev List <netdev@oss.sgi.com>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0410210912280.18310@filer.marasystems.com>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--MW5yreqqjyrRcusr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 21, 2004 at 09:12:48AM +0200, Henrik Nordstrom wrote:
> On Thu, 21 Oct 2004, Harald Welte wrote:
>=20
> >This is the first patch, adding something similar like nfmark, but on a
> >per-conntrack (as opposed to per-skb) level.  Very useful especially for
> >asymmatric routing in combination with MASQUERADE, as often found on
> >home DSL setups with dymamic IP address that also have e.g. a tunnel
> >device with static IP.
>=20
> Is this with or without the mark operations?

What is 'this' you are referring to?=20

'patch'? Well you should know your patch ;)

'very useful'? Yes, indeed.  I think it is already very useful, even
without MARK bit-wise operations (which AFAIK are not implemented with
the required compatibility issues we discussed at the netfilter
workshop, but which will be submitted once this is done).

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--MW5yreqqjyrRcusr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBd35wXaXGVTD0i/8RAijmAJ4oHZSAHJ3wSN9eODFhVoqibYEkbQCfdP/Q
oORpoVyrPojTod4DV94OR58=
=UZ31
-----END PGP SIGNATURE-----

--MW5yreqqjyrRcusr--
