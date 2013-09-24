From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 02/10] intel: Remove extern from function
	prototypes
Date: Tue, 24 Sep 2013 15:07:29 -0700
Message-ID: <1380060449.2189.6.camel@jtkirshe-mobl>
References: <cover.1380056108.git.joe@perches.com>
	<5ccc921af41a862fe969809228f029035f851502.1380056108.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2113846401702495357=="
Cc: Don, e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Jesse
To: Joe Perches <joe@perches.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <5ccc921af41a862fe969809228f029035f851502.1380056108.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============2113846401702495357==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-f7T30DymDb+35Lv0wJp7"


--=-f7T30DymDb+35Lv0wJp7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2013-09-24 at 14:09 -0700, Joe Perches wrote:
> There are a mix of function prototypes with and without extern
> in the kernel sources.  Standardize on not using extern for
> function prototypes.
>=20
> Function prototypes don't need to be written with extern.
> extern is assumed by the compiler.  Its use is as unnecessary as
> using auto to declare automatic/local variables in a block.

So you are able to confirm that all compilers make this assumption
correctly?  The initial reason for using extern was because not all
compilers made the assumption or made it correctly.

--=-f7T30DymDb+35Lv0wJp7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSQg0hAAoJEOVv75VaS+3Oz9sP/Rd3iytGfwfsAnfeEMxely30
UjfgNOTaCXr7vEzWmRqG6xIgFiSmQ0f3no7RiYI70Ob2GUZgSkZ0KUvYFoOK2XTk
l57aV2MXixEP6Cl+RpcpinCP98LIx9O/AM927WNY3ZoJEs3MSB01ly9/dhSKz2oo
HGDNw/fF9QXSVguATwnsBCPmmKMN0OTNgoN73dptKl1WNk4oK4d0byr9UzWjyh6j
JzIZ3g1B9VIa9gFMdZwW2VHRhyi+4FoxQu2Z53DTJ/RP/gF/VDZpUmRx8ZusQsF4
/2N4HQxNR8udy7gH8MaSDP8KnWrh3zQGmpqLs9XUiI5Jgr8pqA7UF9cxRg20Q2Sy
3JBNOzsABBBU6s7Omi0V9Iq1nH77v5m3wVLA0wdiiyaYEq7wnO5EWS2qCkFWPwPK
Ie7tz1EYuAUk4aqzdbdsaE5KlxtTsgmcf0vd6DT1Gg56+E2UKqibI+MdaHqssbdE
AQcuSiLPMGVmeJWJJAsqBoVi8GGlL0i/9aacF3LLtU0bFKIMlk1GFBp0u7kI4OeZ
8tgbpeIAMrXk6VF/wrSIWZU9eh/o13lrsO6sR45Mpfrqbr33gHmhFLKUtzHJmG6a
5FK1ePkIgm8A/eK+LbiWwoBsez8VZcGKu5rQtNyqz1Y9Ci5Iw8o4ZBREMkiGigZn
UGkfhpwuTXhzdOl782qb
=+Qk0
-----END PGP SIGNATURE-----

--=-f7T30DymDb+35Lv0wJp7--



--===============2113846401702495357==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
October Webinars: Code for Performance
Free Intel webinars can help you accelerate application performance.
Explore tips for MPI, OpenMP, advanced profiling, and more. Get the most from 
the latest Intel processors and coprocessors. See abstracts and register >
http://pubads.g.doubleclick.net/gampad/clk?id=60133471&iu=/4140/ostg.clktrk
--===============2113846401702495357==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2113846401702495357==--
