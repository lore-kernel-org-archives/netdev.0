From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 18:05:53 +0100
Message-ID: <1577821.Q7gttkPE2J@avalon>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<20131029060427.GF11580@verge.net.au>
	<20131029160449.GD16686@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4918095343803587038=="
Cc: , linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Guennadi Liakhovetski <g.liakhovetski+renesas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Laurent Pinchart <laurent.pinchart+renesas-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>,
	ed.com-i9wRM+HIrmnmtl4Z8vJ8Kg761KYD1DLY@public.gmane.org, Vinod Koul <vinod.koul-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eduardo Valentin <eduardo.valentin-l0cyMroinI0@public.gmane.org>,
	Tomi Valkeinen <tomi.valkeinen-l0cyMroinI0@public.gmane.org>, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Zhang Rui <rui.zhang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chris Ball <cjb-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>,
	Jean-Christophe Plagniol-Villard <plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org>,
	linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pwm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ian Molton <ian-zdned+2MO1+9FHfhHBbuYA@public.gmane.org>, Simon Horm
To: Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131029160449.GD16686-GFdadSzt00ze9xe1eoZjHA@public.gmane.org>
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


--===============4918095343803587038==
Content-Type: multipart/signed; boundary="nextPart3771148.DUBN0oL5aB"; micalg="pgp-sha1"; protocol="application/pgp-signature"


--nextPart3771148.DUBN0oL5aB
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi Mark,

On Tuesday 29 October 2013 09:04:49 Mark Brown wrote:
> On Tue, Oct 29, 2013 at 03:04:27PM +0900, Simon Horman wrote:
> > I think this is a step in a good direction.
> > However, I think it would be even better if the architecture dependency
> > was removed completely.
> 
> Yes, please.

I've kept it for two reasons.

The first one is that I can't compile-test all those drivers on all 
architectures. The spi-sh-msiof driver, for instance, uses io(read|write)(16|
32) which are not available on all architectures. There might be other similar 
problems that I can't catch, and I don't want to introduce build breakages in 
the kernel.

The second reason is that, as the IP cores have never been used on anything 
but SuperH and ARM, I don't like the idea of clobbering the config process 
with drivers that are useless on the target architecture. Now that we have a 
COMPILE_TEST Kconfig option, my preference would thus go to SUPERH || ARM || 
COMPILE_TEST over no dependency at all.

-- 
Regards,

Laurent Pinchart

--nextPart3771148.DUBN0oL5aB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQEcBAABAgAGBQJSb+r2AAoJEIkPb2GL7hl19w8H+gJj3zKx1Th48UvyGZV3QsU0
AEq9ko2/u+rnJtA2vWyrc6Kfjp07Sa6vVOrY/5s9Mzg69jHQ96KzMTmwbv4/ExoW
6Io3iKE6MdHBnnZ0xPRtNlaE6StlOt4Lv9+rQheJsomFgaRCmvKEaJLOB32bRkgb
AfqFT8gu1OaKF72FhxwJ0Atl2kIJIMLZuaI0bMjRCaK2oDvV2NhufAUGRjuuMFFw
/zQ0wxDIZTUQcu6OXEfa8CA5b5EvcW8v46a+BF+C7nVC4TF4wqgxlhJxxgXcd3mO
pK7clYQn+8d2zpaS7CAMbXXip6r+AO83S8NjR/tDA5er/dyNJ+cskIb5kxNes34=
=9Krm
-----END PGP SIGNATURE-----

--nextPart3771148.DUBN0oL5aB--


--===============4918095343803587038==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============4918095343803587038==--
