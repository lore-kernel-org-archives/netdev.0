From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 1/2] regmap: only call custom reg_update_bits() if reg is
 marked volatile
Date: Tue, 6 Oct 2015 14:37:38 +0100
Message-ID: <20151006133738.GQ12635@sirena.org.uk>
References: <1444051772-20270-1-git-send-email-jon@ringle.org>
 <20151005145722.GT12635@sirena.org.uk>
 <20151005.232956.105884641412802470.davem@davemloft.net>
 <20151006101305.GG12635@sirena.org.uk>
 <ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="xeZ3YA8+Vf61r4iB"
Cc: David Miller <davem@davemloft.net>,
	"jon@ringle.org" <jon@ringle.org>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jringle@gridpoint.com" <jringle@gridpoint.com>
To: Jon Ringle <jonringle@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ABC562FD-5DE5-452E-8DE6-1C436E37E8BE@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xeZ3YA8+Vf61r4iB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 06, 2015 at 08:50:43AM -0400, Jon Ringle wrote:

> 4) David should then merge the regmap for-next branch into net-next

What I generally do (and what's best practice in general for cross tree
work) is apply patches on topic branches and then create a signed tag
for anything that's being merged into another tree.  That both means
we've got a signed tag for the chain of trust in the code and means that
only the specific dependency gets pulled into other trees rather than
everything that's queued.  Minimising what's pulled in makes pull
requests look cleaner and avoids noise from in development code
appearing in other trees (eg, any bugs in other code that's not quite
ready won't get merged).

In my specific trees nobody should ever merge my for-FOO branches,
they're rebuilt frequently - the topic branches are fast forward only
and intended for that (though like I say a signed tag is best).  Linus
complains about keeping the for-FOO branches fast forward
only.

> 5) I will submit a new patch to net-next for the encx24j600 driver
> that should build against the regmap changes

> Sound like a good plan?

Makes sense to me modulo the signed tag thing above.

--xeZ3YA8+Vf61r4iB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWE86dAAoJECTWi3JdVIfQ77AH/iDZtUFR4NykCw0zTSodoXMW
vuAwG0hl3quO6t0bn53C6AIpSKewF+b4Ly3q+mEKqU/zUunST+sxnZOi7ue7ZK4I
7yWTQV7whlN9CcB6/KGrC6wSO1QN6fxBho50KFvBulRa6+HhI0Y5lHJQ4knFK97u
bQKAMt9r+xbar/XK7Pjms/0WLDrTfuO3GQWgek3bIC+9ySAfzo47v9VgyJA98zGo
o1Tr6Pn2JMZaOz1N35nCCZ5nlN1to8l9Yl9FOUQM7X5IZeCduvVX8myko7jlW91l
iKuCh+QvZT+qq+FxB5f5ImSc8QUhnfMTw086XlhkAHEWyKoKLa/2KT0SlorJNjA=
=Ahnl
-----END PGP SIGNATURE-----

--xeZ3YA8+Vf61r4iB--
