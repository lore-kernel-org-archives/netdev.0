From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Wed, 28 May 2014 20:49:13 +0100
Message-ID: <20140528194913.GI5099@sirena.org.uk>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
 <1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
 <20140524124858.GR22111@sirena.org.uk>
 <5385063F.30407@codeaurora.org>
 <20140528151646.GU20155@pengutronix.de>
 <20140528171219.GD5099@sirena.org.uk>
 <53863CA3.7040000@codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tSiBuZsJmMXpnp7T"
Cc: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
	"David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53863CA3.7040000@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tSiBuZsJmMXpnp7T
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 28, 2014 at 12:44:35PM -0700, Stephen Boyd wrote:
> On 05/28/14 10:12, Mark Brown wrote:

> > If the supply must always be physically present the bindings should be
> > specified as it being mandatory and the code written in that fashion; as
> > an extension Linux will put a dummy in but this is attempting to handle
> > incorrect DTs.  This means we have functional error handling in cases
> > where there is something to worry about and simplifies the code using
> > the regulator.

> Ok, you're saying the opposite of Rob. Should it be required or optional
> in the DT binding?

I'm saying it should be required.  The implementation accepts it as an
extension (a recent extension at that).

> Ok. Dave M has already picked up all these patches so I'll send a patch
> to replace regulator_get_optional() with regulator_get() and fix up the
> error handling unless I hear otherwise.

Yes, please.  I'm much more worried about the abuse of
regulator_get_optional() than the binding.

--tSiBuZsJmMXpnp7T
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJThj22AAoJELSic+t+oim9YCQP/3X79T9pZF6Mlt7qgfAAzkt5
1tOJAXcsj11VYtwdVp61JJsmluCnYCK7LrGCoVBiv4wcgraaV0fivPpESjrC0SL6
jf9JDo2G9QBFafd7uMkrUGmEfd0CEk/CrESX3qD+AWHiQe/cpQwhZGGmP4ArFg22
PNwRHPnXrPOS1hFxJstcpKZBdG1VwK5EnXuQpTiA36SljLyQz0BUJeK8HOofmAHn
3aOeUf5OE8Sp1ktAG0VLvBCBwVNhkz0VdFfrEYweWJ0FX2dvBtvM7QppDBY5EHgY
2L8XYPK6F7+QkEDzZNKmCh+TUfjrdOEUiH9417Ewq8FAf/IK6G6v4xL/pKkeONN6
3Gs0K+UoBRkMi2fVakiaaFxac+B4zWK290aIIhEFnRsq5x+KXUzrvtbgRwpfIQO5
EhvsP67SImY5Q2JmeDC2suSQwoG+HKzhtrekwViIX7LEozPSheTiPTzYWd6aMUlQ
UOUZfpb4FSxo/W9xUvZkVUlGslYuBECyqBDQRyDc9zr2cRiYb22vh/K+qs+OkPYl
1Jf+4dhenqAgDvHr+JPne78DSW9cNXCA8+Us0SPPckgT11aKexEzH+sFeWNhuxZ0
Zr2//CD75J7DTxbswucidzNFhE6o6G6xddPlHyKjl4gGau3bU8VyV9X+MMhYYCBi
gJ3TAaMcWyrE1zuPUtsB
=lp/p
-----END PGP SIGNATURE-----

--tSiBuZsJmMXpnp7T--
