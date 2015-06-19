From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v2 1/3] net: mvneta: introduce compatible string
 "marvell, armada-xp-neta"
Date: Fri, 19 Jun 2015 14:32:53 +0200
Message-ID: <20150619123253.GB4853@kw.sim.vm.gnt>
References: <1434547162-6275-1-git-send-email-simon.guinot@sequanux.org>
 <1434547162-6275-2-git-send-email-simon.guinot@sequanux.org>
 <55818E64.20007@free-electrons.com>
 <55818F10.8030304@free-electrons.com>
 <20150617170112.GD2917@io.lakedaemon.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HYC+c85AsWjroYih"
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	stable@vger.kernel.org, Vincent Donnefort <vdonnefort@gmail.com>,
	linux-arm-kernel@lists.infradead.org,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:46557 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbbFSMc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 08:32:58 -0400
Content-Disposition: inline
In-Reply-To: <20150617170112.GD2917@io.lakedaemon.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--HYC+c85AsWjroYih
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 17, 2015 at 05:01:12PM +0000, Jason Cooper wrote:
> Hi Gregory,
>=20
> On Wed, Jun 17, 2015 at 05:15:28PM +0200, Gregory CLEMENT wrote:
> > On 17/06/2015 17:12, Gregory CLEMENT wrote:
> > > On 17/06/2015 15:19, Simon Guinot wrote:
> > >> The mvneta driver supports the Ethernet IP found in the Armada 370, =
XP,
> > >> 380 and 385 SoCs. Since at least one more hardware feature is availa=
ble
> > >> for the Armada XP SoCs then a way to identify them is needed.
> > >>
> > >> This patch introduces a new compatible string "marvell,armada-xp-net=
a".
> > >=20
> > > Let's be future proof by going further. I would like to have an compa=
tible string
> > > for each SoC even if we currently we don't use them.
>=20
> I disagree with this.  We can't predict what incosistencies we'll discove=
r in
> the future.  We should only assign new compatible strings based on known =
IP
> variations when we discover them.  This seems fraught with demons since we
> can't predict the scope of affected IP blocks (some steppings of one SoC,=
 three
> SoCs plus two steppings of a fourth, etc)
>=20
> imho, the 'future-proofing' lies in being specific as to the naming of the
> compatible strings against known hardware variations at the time.

So, should I add more compatible strings or not ?

Simon

--HYC+c85AsWjroYih
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWEC/UACgkQgtp0PDeOcDrQlwCfdsYQWiiyYkklsn5EbYAm/7ds
DcEAn3xzH2P7zKkUChH+4vJ8uX2r7Lcc
=HhAi
-----END PGP SIGNATURE-----

--HYC+c85AsWjroYih--
