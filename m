From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: [RFC] acx100 inclusion in mainline;
	generic 802.11 stack
Date: Tue, 28 Sep 2004 08:20:28 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040928122028.GK30131@ruslug.rutgers.edu>
References: <200408312111.02438.vda@port.imtp.ilyichevsk.odessa.ua>
	<1094628909.1097.145.camel@jzny.localdomain>
	<413F2D33.1000508@atheros.com> <200409082251.45771.vkondra@mail.ru>
	<413F70F0.6020709@atheros.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0540870989=="
Cc: netdev@oss.sgi.com, jkmaline@cc.hut.fi,
	acx100-devel@lists.sourceforge.net,
	Vladimir Kondratiev <vkondra@mail.ru>, hadi@cyberus.ca,
	prism54-devel@prism54.org, vda@port.imtp.ilyichevsk.odessa.ua,
	sam@errno.com, jgarzik@pobox.com,
	"David S. Miller" <davem@davemloft.net>
Return-path: <prism54-devel-bounces@prism54.org>
To: greg chesson <greg@atheros.com>
In-Reply-To: <413F70F0.6020709@atheros.com>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0540870989==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Pk/CTwBz1VvfPIDp"
Content-Disposition: inline


--Pk/CTwBz1VvfPIDp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 08, 2004 at 01:52:00PM -0700, greg chesson wrote:
>=20
>=20
> Vladimir Kondratiev wrote:
> >Greg,
> >you missed one important point. Besides data packets, that every driver=
=20
> >now convert .11<->.3 using almost the same code, there is whole story of=
=20
> >management. Many modern cards are "softmac" and do all management on hos=
t.=20
> >I see no point for every driver to implement its own scanning and=20
> >association.=20
>=20
> Yes, Quite right.  No disagreement.
> It is standard practice on NDIS and Apple Darwin that a common GUI-based
> application controls scanning, association, and manages=20
> keys+authentication+crypto.
>=20
> Linux does the same thing (driver is configured by application code)
>  although there does not yet exist a single app
> that can serve as a common point of control for multiple vendor drivers.
> I believe that achieving that goal is the real payoff for wireless Linux=
=20
> users.
>=20

<-- snip -->

RFC: what are the chances we can implement our own generic "softmac" that m=
ay
be usable by the different chipsets out there?

	Luis

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--Pk/CTwBz1VvfPIDp
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBWVcMat1JN+IKUl4RAu4NAJoDo42bsPBum54qQZ+Z1bqDSz5ibgCfROrd
IQ2LOtHHbfTgIdxSXjLPRLk=
=aWPg
-----END PGP SIGNATURE-----

--Pk/CTwBz1VvfPIDp--

--===============0540870989==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0540870989==--
