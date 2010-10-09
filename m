From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv5] net: Add batman-adv meshing protocol
Date: Sat, 9 Oct 2010 14:34:41 +0200
Message-ID: <201010091434.42986.sven.eckelmann@gmx.de>
References: <1284836610-26799-1-git-send-email-sven.eckelmann@gmx.de>
	<20100924.134334.28812338.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1563780.u9FV9mOrzV";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20100924.134334.28812338.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1563780.u9FV9mOrzV
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
> Date: Sat, 18 Sep 2010 21:03:30 +0200
>=20
> > B.A.T.M.A.N. (better approach to mobile ad-hoc networking) is a routing
> > protocol for multi-hop ad-hoc mesh networks. The networks may be wired =
or
> > wireless. See http://www.open-mesh.org/ for more information and user
> > space tools.
> >=20
> > Signed-off-by: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
>=20
> The only thing remaining which I really don't like is this hash helper
> library thing in here.
>=20
> It's a terrible abstraction and very inefficient.  Iteration uses
> function calls, as does removal.  Key comparisons use callbacks, via
> indirection function pointers, also very inefficient.

I would completely agree.

> Just use the "struct hlist_head" and "struct hlist_node" objects we
> have generically already.  Inline the list iteration, as well as the
> key comparisons and the node linking/unlinking.

hlist_head and hlist_node is the right thing to do, but I am a little bit=20
irritated by the rest.

Ok, no hash implementation from the basics, but there is functionality shar=
ed=20
by the four hashing tables used, which I would not like to "implement" agai=
n=20
everywhere. For example the "add to hash if data isn't already added there"=
=2E=20
This can easily done using a static inline function which receives a=20
comparison and choose/key function (which also can be inlined by the compil=
er)=20
and does the rest using hlist_*.

Speaks anything against such things shared in inside batman-adv only?

thanks,
	Sven

--nextPart1563780.u9FV9mOrzV
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMsGFhAAoJEF2HCgfBJntGueUP/jNPBrZJg3NST3sgg5GCd5b7
BcByPmH2oOPkUZKfXeOrwxWuYLotsW64Cd6yWMlXQqRJAdQwnGP+p1iy884yiBJ7
GOkw6FH5FeCqdQgYm9d/gkqN29sw9swgNBCvDf8KnylqnnfBIGrQ0TdLvkv1e0D2
7Jo+o9DzHofEE9S1JRsRy5yitRYxeyh++bRbwKOtQC3MEM5uTQVpQdNyPjWAfhRn
ogPYC4huiNNc8sHVzS6tidEbYUZDGaKN4rCZKEjpo4psAy+r0c2w44H1RRILvYGL
3BU164DY52JiXBxwIOm/Hn21TFdQbOBKiaiH/dCzZTpbOt+5Gjiin+lIAyeezUAw
/DnPwoghFAxDjSyPeYpGteZy71iLYFIVAL8PzCZrNlFiaoL4gpSiaNnN0jcE+YMd
dGd9xHjhUgslYGaVv3pDtrVJd5GjLo4KNc4khJUDVVvk6UU3G1c2OQ2UbtcQ0GaR
icY9NuqWxfoHhmpLQAzGQN6Pg/w5JPwfpIZYi0fEXIZmkPtxKlYE4VSvWhfWMx/h
LcYaEfBmlankfU5BY2e6wSHZoZY90b1NDxHXerxppLWA5eP4FMKe3Jk6bPDtU4Cx
VJ1Gh4dRXTQ6O6hIZg3UyOCk0TMrZB481O1Nlj+dR0lNLj9EQOfr8mbOtxO4G/nh
fbVxYDHEF/OUC5c+7dGv
=3P3X
-----END PGP SIGNATURE-----

--nextPart1563780.u9FV9mOrzV--
