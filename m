From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 10:58:34 -0700
Message-ID: <20131029175834.GD20251@sirena.org.uk>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<1577821.Q7gttkPE2J@avalon> <20131029172331.GA20251@sirena.org.uk>
	<1422562.0L87CDt5Gd@avalon>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8904243574837400148=="
Cc: linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guennadi Liakhovetski <g.liakhovetski+renesas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Laurent Pinchart <laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>,
	Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>,
	Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>,
	linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>, Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
	linux-arm
To: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1422562.0L87CDt5Gd@avalon>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org


--===============8904243574837400148==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="d9ADC0YsG2v16Js0"
Content-Disposition: inline


--d9ADC0YsG2v16Js0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 29, 2013 at 06:29:59PM +0100, Laurent Pinchart wrote:
> On Tuesday 29 October 2013 10:23:31 Mark Brown wrote:
> > On Tue, Oct 29, 2013 at 06:05:53PM +0100, Laurent Pinchart wrote:
> > > The first one is that I can't compile-test all those drivers on all
> > > architectures. The spi-sh-msiof driver, for instance, uses
> > > io(read|write)(16|

> > Which architectures are these and is there not a symbol we can depend on
> > for them?

> arch/cris for instance. We can use readl/writel instead (maybe it would b=
e=20
> time to rationalize and document the I/O accessors across all architectur=
es,=20
> but that's another topic).

It'd certainly be sensible, or adding a config option to depend on if
you rely on these functions.

> My point is that there might be other issues that I won't be able to easi=
ly=20
> catch. This would break compilation for everybody for no reason, as the=
=20
> drivers are useless on non-SuperH, non-ARM platforms. That's why I believ=
e=20
> COMPILE_TEST would be a better option as a first step.

Yes, it would - please do that.  Note that it won't stop anyone running
into build issues on other architectures though, it's just about
stopping Kconfig noise.

--d9ADC0YsG2v16Js0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSb/dHAAoJELSic+t+oim9ddQP/i1RCiwSI2llH07cDu0C60zD
gD/NLQYokpqOLuYQkIqY/ODY7avbL/f0ZuAbQ6BhfmQWWaX9sDLM1YmJTbbYEcFr
rhCqyLRj7dWwM+R4j5HkiZ5rSNxKJS6D5kPHdkwS7BJyxlyzaIHlbxb49V4WKfwB
UH3YFNpz4QbkFg2vE8/trXMW2roqYxKTEal5OktM0EeMHPhjFYZQmXyOin5Fd3Re
yp4gCnSDZ+rHEZjPevraos5ZTf4IGB57EaFYk8whSuG/U1hzepXShgCPF76eJjmZ
VoyrL+ZXPn67V8Tiym/GHOROG9bSzUvoKTvXB7SF0t0WY2ypgFGrNOQFfDOBYqkL
9s3o+k3hPdmDenFZXUL4qpW/CX9Q0XsapsCKfK1wPXHRLgKWa/oUlLOfQZFIXNFU
yNXqvnrOlq6T8B5wqohi9ZvwqlDVWtsSc43mE8pfIkgd/Dr24QlhOHsmlee7nq+y
KeZKoZ4tIEsYuYSYZV8UG1SvBw2WSTH0tEvkHOr6kJpdUwNrQ7llEvw531KMqvsF
eJ+AfYZcPM7tNPRTDwvqNeJW1qgsVdCan7U2UcIUWjx26Bz49eb6VykEcQx9LnRJ
J+egZaXBWhep+9xCuk+fskdIKlawPmxy2ImBh9M8Fn7o/UnDdAmMuI3xE8k/njRp
5YMTmmm5fewQmrrmmAws
=dlcY
-----END PGP SIGNATURE-----

--d9ADC0YsG2v16Js0--

--===============8904243574837400148==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============8904243574837400148==--
