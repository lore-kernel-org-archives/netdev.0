From: Sven Eckelmann <sven.eckelmann-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCHv4] net: Add batman-adv meshing protocol
Date: Tue, 7 Sep 2010 20:24:51 +0200
Message-ID: <201009072024.53048.sven.eckelmann@gmx.de>
References: <1283646353-17811-1-git-send-email-sven.eckelmann@gmx.de>
	<201009071956.54499.sven.eckelmann@gmx.de>
	<20100907181000.GF2448@linux.vnet.ibm.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3312287.PMbKDDce3f";
	protocol="application/pgp-signature"; micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwlltHuzzzSOjJt@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20100907181000.GF2448-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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

--nextPart3312287.PMbKDDce3f
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Paul E. McKenney wrote:
[..]
> > > I have similar concerns with your other RCU read-side critical
> > > sections.
> >=20
> > Looks to me like a valid point. I have to think a little bit how to sol=
ve
> > it correctly. Feel free to add more comments about other rcu cruelties
> > in it.
>=20
> One approach would be to extend the RCU read-side critical section to
> cover all uses of the RCU-protected pointer.  Another approach would be
> to take a reference count (or something similar) before the pointer
> leaves the RCU read-side critical section.

I am not the author of the rcu related functionality (it was one of the act=
ual=20
maintainers: Simon Wunderlich), but would guess that the rcu protected=20
"critical section" will be extended.

> Could you please take a look at Documentation/RCU/checklist.txt?
>=20
> Because I am not familiar with the BATMAN device, it is all too easy
> for me to miss subtleties in the code.

Yes, will be done (will probably end in reading all the rcu documentation).=
=20
But it is really nice that you checked the code for your area of interest.

thanks,
	Sven

--nextPart3312287.PMbKDDce3f
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAABCgAGBQJMhoN0AAoJEF2HCgfBJntGdYkQALvr+YpSccrJriQDihslXiIp
bvw0WE9K05E1D8DjqT9H8vo/qptnGtIFhMQlUB1GsN1JVVmpxE5J6tvEbCZPVcyv
uTYEkSkwlBDJe6sSEApqLSc8fkZR4dn882pgJTm32cRN3M843eFy80g3MJ39TnZh
6UhHK5rh/WI/p6Q+GXX/LMYbrBqWgGMK4yssv3dDTHohRXOa8Y4nwlGBesmuJgbM
BizlL04XY7iDUv4npHl/jV0xE292wP/QZet2HvszlQmWJDDtGAU9Yc8wP002Py+z
pBvcJSH3K5UCX5Ab1V8R6htCMOY/Jp7OTKqOMFq5EEdRMqHdeiOTXH3+iPj5DzJG
2NJuACyN1Gtk4chOnlFHSE2F21FflI9JDOmwmpP2VqnC1Pl7pKlzyhsuwgv+9ww4
rYXPPkmWJZBLYeQvE79mxRp7GwE62X7ZNLRPirSdZtYoZyWIOUAqYYHLMJqe/PwM
8wxT+obzrJf/6FIXs9gOVIeWY2oEloqTEJ2IPVAPawF1IBgzG5Abhn8xfB6+GrxI
fEdlHzIr9XPsFef/xZ8vDTH/CoK9HNTxMUe9D/rB0XJxssf7pxWd1c58V9B36bB7
8b+b7yECXAhCa79XWhiWI4081dp8eVy+FR1tywZHoozrBsPdZ8y6vpLtgUbNgj43
0MycGskEVE/HjxnZ60ut
=SZ2s
-----END PGP SIGNATURE-----

--nextPart3312287.PMbKDDce3f--
