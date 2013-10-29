From: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 10:23:31 -0700
Message-ID: <20131029172331.GA20251@sirena.org.uk>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<20131029060427.GF11580@verge.net.au>
	<20131029160449.GD16686@sirena.org.uk> <1577821.Q7gttkPE2J@avalon>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5400421835194494799=="
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
In-Reply-To: <1577821.Q7gttkPE2J@avalon>
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


--===============5400421835194494799==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wac7ysb48OaltWcw"
Content-Disposition: inline


--wac7ysb48OaltWcw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 29, 2013 at 06:05:53PM +0100, Laurent Pinchart wrote:

> The first one is that I can't compile-test all those drivers on all=20
> architectures. The spi-sh-msiof driver, for instance, uses io(read|write)=
(16|

Which architectures are these and is there not a symbol we can depend on
for them?

> 32) which are not available on all architectures. There might be other si=
milar=20
> problems that I can't catch, and I don't want to introduce build breakage=
s in=20
> the kernel.

This is easy enough to handle if we do run into issues, it seems better
to get things available than try to step through architecture by
architecture.

> The second reason is that, as the IP cores have never been used on anythi=
ng=20
> but SuperH and ARM, I don't like the idea of clobbering the config proces=
s=20
> with drivers that are useless on the target architecture. Now that we hav=
e a=20
> COMPILE_TEST Kconfig option, my preference would thus go to SUPERH || ARM=
 ||=20
> COMPILE_TEST over no dependency at all.

That's not what you did, though - you're not adding COMPILE_TEST.

--wac7ysb48OaltWcw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSb+8QAAoJELSic+t+oim9cO4P/0CNsXH4RTd+b7gkEaGIE5FB
749OqmwnlVvQPjycW5R0GiBevc7Iw9QehjcuZlE4aviXL6IWaPDr3tAOsTEuf+RZ
mVZ8NLpDCdPHzLG9/2LPPZ3JcsOAbayMDkjlLZL3Ozf0eimalO7f5Lkuj5qPHcop
FP8gmnlApKD9xCWamFEm+XJy7NGEMdzhuUUdJcDiAQ64sMfc40YBpdkbBH8GR/jp
OG07H8nOdyGWfL516EBO4yK5bHrP7oIJIBFL8KXrf5aQVx4gRoqouX7OjVvBl7uY
qZlCpOZY8aow93HdJlC/skjiKCAR33kXFmVShNF6FgDpzCkWHwQ38oU2kH0KqL+L
YbpZeZbZ6ZW2s6je9cwlq+KZG2ngYdVYPozN+a+jyLlLMDGXKjOaHU4Ctrf25jr8
0WU70ZaDfARfn4kJ3pRs0CTmRmAZXezVlPQZkKp57IqAlogCgzDNkIvL17DbCy1C
HkloKaMlvlUgOBJolYNvpas7V/cRz2BB132UXoIvSI94EkXCkQJ3vVvrLmXncbG3
TNCyyLGe5uzBeC2z5CnIoGRTmX8rMjDVsmK81f0YCCoaLMWXUc/CG6V1pRurcmdN
bNC9b0miP+ZLoxe6enERCPcqK8YM1m/d2pMv9EzDRw6kG6Htu8T1DjxQOpHWeOTG
aWRAEtmK2IU5cZjenCxT
=r5xl
-----END PGP SIGNATURE-----

--wac7ysb48OaltWcw--

--===============5400421835194494799==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============5400421835194494799==--
