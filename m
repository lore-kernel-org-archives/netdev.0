From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: [E1000-devel] [PATCH] e1000: Allow the driver to be used on PA RISC C8000 workstation
Date: Mon, 27 Jun 2011 20:42:13 +0200
Message-ID: <1793556.1X3EUabhs6@donald.sf-tec.de>
References: <A78C6259B11833419567082E2DC0C25601D8A9CA5E@orsmsx508.amr.corp.intel.com> <1538517.jd8kKEpd3f@donald.sf-tec.de> <2567734.3Tpd1BeV4a@donald.sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1841349.UNopVYvNRc"; micalg="pgp-sha1"; protocol="application/pgp-signature"
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:44157 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961Ab1F0SmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 14:42:13 -0400
In-Reply-To: <2567734.3Tpd1BeV4a@donald.sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart1841349.UNopVYvNRc
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="ISO-8859-1"

Rolf Eike Beer wrote:
> Am Freitag, 18. M=E4rz 2011, 17:39:57 schrieb Rolf Eike Beer:
> > Am Mittwoch, 2. M=E4rz 2011, 21:19:24 schrieb Jesse Brandeburg:
> > > On Mon, Feb 28, 2011 at 5:40 AM, Guy Martin <gmsoft@tuxicoman.be>=
 wrote:
> > > > Hi Jeff,
> > > >=20
> > > > Any luck getting this into mainline ?
> > >=20
> > > Hi Guy, sorry for the delay,
> > > We haven't been able to get our contacts in HP to give us a decen=
t
> > > response so far, we are following up with them to see whats up.  =
We
> > > have not lost the patch and are still tracking it internally.
> > >=20
> > > Give us a couple more weeks if that is okay and we should be able=
 to
> > > settle this by then.
> >=20
> > I wonder what exactly you are waiting for? This is a sanity check t=
hat
> > we
> > disable, so no working systems could get broken by this. And every
> > single
> > C8000 seems to be affected by this and is working fine with that pa=
tch.
> > So maybe people at HP might have a clue _why_ this is screwed, but
> > until then I don't see any point in waiting.
> >=20
> > So please just add my tested-by and push this upstream soon. Since =
this
> > is basically a hardware quirk I would like to get this into stable =
also
> > so we may run vanilla 2.6.38.1 or something like that on C8000.
> >=20
> > Tested-by: Rolf Eike Beer <eike-kernel@sf-tec.de>
>=20
> For the netdev folks: it's this patch we are talking about
>=20
> http://www.spinics.net/lists/linux-parisc/msg03091.html
>=20
> I would love to see that someone finally picks this up and pushes thi=
s
> upstream, CC stable. This is absolutely annoying as it breaks every t=
ime
> anyone touches the kernel on one of this machines.
>=20
> Jeff, David, James: can you please make a decision of who takes this =
and
> then just do it?

Ping?
--nextPart1841349.UNopVYvNRc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAk4IzwoACgkQXKSJPmm5/E6OMgCfTwhe6TGgtXF1RhKMQnUwstRc
aRMAni32uPD+RUBsPA3SMiojgmDNogDT
=zdUg
-----END PGP SIGNATURE-----

--nextPart1841349.UNopVYvNRc--

