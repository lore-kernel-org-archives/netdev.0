From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 13:56:22 +0200
Message-ID: <20050812115622.GD16325@rama.de.gnumonks.org>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<42FC0F01.5090802@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="u65IjBhB3TIa72Vp"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42FC0F01.5090802@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--u65IjBhB3TIa72Vp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 12, 2005 at 04:52:49AM +0200, Patrick McHardy wrote:

> This functions looks broken.=20

I feared it...

> Divisor and divident are mixed up, the
> shifted result variable is not used in the actual division, the
> "first bit has to be < 32" assumption is wrong and num_shift is
> calculated incorrectly. To find a 32-bit divisor consisting of the
> most-significant 32 bits we need to find the highest bit set and
> subtract 32 from this, then right-shift by that value if it is larger
> than 0. I can send a fixed patch tomorrow but I'm too tired now.

Thanks.

> >+	case IPT_CONNBYTES_WHAT_PKTS:
>=20
> I would really prefer the name IPT_CONNBYTES_PKTS :)

I _think_ it's sure to change it, since we don't include ipt_connbytes.h
in the iptables package.

Just send two incremental patches to Dave.

Cheers,
	Harald
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--u65IjBhB3TIa72Vp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC/I5mXaXGVTD0i/8RAlf4AJ9B5l3jkqK48834R5JgNvkdsygjtACfQESa
3WkDxXXQ6n62I3tmZT3z6Ss=
=rSMU
-----END PGP SIGNATURE-----

--u65IjBhB3TIa72Vp--
