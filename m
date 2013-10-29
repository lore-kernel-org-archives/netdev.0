From: Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>
Subject: Re: [PATCH 00/19] Enable various Renesas drivers on all ARM platforms
Date: Tue, 29 Oct 2013 18:29:59 +0100
Message-ID: <1422562.0L87CDt5Gd@avalon>
References: <1383004027-25036-1-git-send-email-laurent.pinchart+renesas@ideasonboard.com>
	<1577821.Q7gttkPE2J@avalon> <20131029172331.GA20251@sirena.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4715544745593348638=="
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
In-Reply-To: <20131029172331.GA20251-GFdadSzt00ze9xe1eoZjHA@public.gmane.org>
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


--===============4715544745593348638==
Content-Type: multipart/signed; boundary="nextPart4942102.gaO6gKkPZo"; micalg="pgp-sha1"; protocol="application/pgp-signature"


--nextPart4942102.gaO6gKkPZo
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi Mark,

On Tuesday 29 October 2013 10:23:31 Mark Brown wrote:
> On Tue, Oct 29, 2013 at 06:05:53PM +0100, Laurent Pinchart wrote:
> > The first one is that I can't compile-test all those drivers on all
> > architectures. The spi-sh-msiof driver, for instance, uses
> > io(read|write)(16|
>
> Which architectures are these and is there not a symbol we can depend on
> for them?

arch/cris for instance. We can use readl/writel instead (maybe it would be 
time to rationalize and document the I/O accessors across all architectures, 
but that's another topic).

My point is that there might be other issues that I won't be able to easily 
catch. This would break compilation for everybody for no reason, as the 
drivers are useless on non-SuperH, non-ARM platforms. That's why I believe 
COMPILE_TEST would be a better option as a first step.

> > 32) which are not available on all architectures. There might be other
> > similar problems that I can't catch, and I don't want to introduce build
> > breakages in the kernel.
> 
> This is easy enough to handle if we do run into issues, it seems better to
> get things available than try to step through architecture by architecture.
> 
> > The second reason is that, as the IP cores have never been used on
> > anything but SuperH and ARM, I don't like the idea of clobbering the
> > config process with drivers that are useless on the target architecture.
> > Now that we have a COMPILE_TEST Kconfig option, my preference would thus
> > go to SUPERH || ARM || COMPILE_TEST over no dependency at all.
> 
> That's not what you did, though - you're not adding COMPILE_TEST.

No, but I can add it :-) If this gets agreed upon, I'll respin the series with 
|| COMPILE_TEST.

-- 
Regards,

Laurent Pinchart

--nextPart4942102.gaO6gKkPZo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQEcBAABAgAGBQJSb/CXAAoJEIkPb2GL7hl1dSgH/3RYsAUPWMftP+1QweJRm6hs
bIhJ6rTB4F54mGzaaAb1Annf8nvl8dlDFCbOg2xMyPxaA3GUzvQWveHt82uZ8fnM
fM2uJfvhVSublzE7ApEvMxBEcVyCtdne+0tg6aiqGQkxtAK2gmDt/92qnRbGP+c4
m3EDrAzSnbhwSA1468pjmuLAxyPIjLFHS0aE/0Z8Z72wrlj2LWkRE3QbMKJNsmic
f04dPUTnDIYpUQVSz9F9t73ytHDUEwee5kVY9OOhZ8RAZjKdNsMToKsI4pTvYsMU
NcihFBJXmFjYqo0Nod9uqsmpF/fGDdq50FWWCZWZfltuGDcLCTbFA9dvd25xCYU=
=NDtx
-----END PGP SIGNATURE-----

--nextPart4942102.gaO6gKkPZo--


--===============4715544745593348638==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============4715544745593348638==--
