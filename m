From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: [E1000-devel] [PATCH] e1000: Allow the driver to be used on PA RISC C8000 workstation
Date: Fri, 06 May 2011 07:58:15 +0200
Message-ID: <2567734.3Tpd1BeV4a@donald.sf-tec.de>
References: <A78C6259B11833419567082E2DC0C25601D8A9CA5E@orsmsx508.amr.corp.intel.com> <AANLkTinga9dW9+4TQzE+f6Tt4kAEiXaprZjv+U+-a5Mq@mail.gmail.com> <1538517.jd8kKEpd3f@donald.sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart10541031.JhSyI9djkO"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Content-Transfer-Encoding: quoted-printable
Cc: Guy Martin <gmsoft@tuxicoman.be>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"kyle@mcmartin.ca" <kyle@mcmartin.ca>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>,
	"mikulas@artax.karlin.mff.cuni.cz" <mikulas@artax.karlin.mff.cuni.cz>,
	netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1538517.jd8kKEpd3f@donald.sf-tec.de>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nextPart10541031.JhSyI9djkO
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="ISO-8859-1"

Am Freitag, 18. M=E4rz 2011, 17:39:57 schrieb Rolf Eike Beer:
> Am Mittwoch, 2. M=E4rz 2011, 21:19:24 schrieb Jesse Brandeburg:
> > On Mon, Feb 28, 2011 at 5:40 AM, Guy Martin <gmsoft@tuxicoman.be> w=
rote:
> > > Hi Jeff,
> > >=20
> > > Any luck getting this into mainline ?
> >=20
> > Hi Guy, sorry for the delay,
> > We haven't been able to get our contacts in HP to give us a decent
> > response so far, we are following up with them to see whats up.  We=

> > have not lost the patch and are still tracking it internally.
> >=20
> > Give us a couple more weeks if that is okay and we should be able t=
o
> > settle this by then.

> I wonder what exactly you are waiting for? This is a sanity check tha=
t we
> disable, so no working systems could get broken by this. And every si=
ngle
> C8000 seems to be affected by this and is working fine with that patc=
h. So
> maybe people at HP might have a clue _why_ this is screwed, but until=
 then
> I don't see any point in waiting.
>=20
> So please just add my tested-by and push this upstream soon. Since th=
is is
> basically a hardware quirk I would like to get this into stable also =
so we
> may run vanilla 2.6.38.1 or something like that on C8000.
>=20
> Tested-by: Rolf Eike Beer <eike-kernel@sf-tec.de>

For the netdev folks: it's this patch we are talking about

http://www.spinics.net/lists/linux-parisc/msg03091.html

I would love to see that someone finally picks this up and pushes this=20=

upstream, CC stable. This is absolutely annoying as it breaks every tim=
e=20
anyone touches the kernel on one of this machines.

Jeff, David, James: can you please make a decision of who takes this an=
d then=20
just do it?

Eike
--nextPart10541031.JhSyI9djkO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAk3DjfwACgkQXKSJPmm5/E7FZQCgjvlHvwJjgD9o5YFDkiI6FH3z
vK0AoIxytoAgWa+wOI6l+wEh+BnmONN7
=6yl3
-----END PGP SIGNATURE-----

--nextPart10541031.JhSyI9djkO--

