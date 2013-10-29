From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 2/4] wl1251: move power GPIO handling into the driver
Date: Mon, 28 Oct 2013 18:33:18 -0700
Message-ID: <20131029013318.GC16686@sirena.org.uk>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-3-git-send-email-sre@debian.org>
 <1382891056.102746625@f315.i.mail.ru>
 <20131027201218.GA4414@earth.universe>
 <CANOLnONKcC1i19ypb4rh2Rff3WsVhhuUhNvZvYwDV2-ZNtjVxQ@mail.gmail.com>
 <20131028192354.GA18208@sirena.org.uk>
 <20131028232624.GA950@earth.universe>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WfZ7S8PLGjBY9Voh"
To: Grazvydas Ignotas <notasas@gmail.com>,
	Alexander Shiyan <shc_work@mail.ru>,
	Luciano Coelho <luca@coelho.fi>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Tony Lindgren <tony@atomide.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Stephen Warren <swarren@wwwdotorg.org>,
	linux-doc@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Rob Herring <rob.herring@calxeda.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Felipe Balbi <balbi@ti.com>, Rob Landley <rob@landley.net>,
	netdev@vger.kernel.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131028232624.GA950@earth.universe>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WfZ7S8PLGjBY9Voh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Oct 29, 2013 at 12:26:26AM +0100, Sebastian Reichel wrote:

> 1. The pin is named PMEN in the Nokia N900 schematics
> 2. PMEN is described as "Power management enable - system shutdown"
>    in a crippled datasheet of the wl1253, which I found in the internet.

> I don't think this is supposed to be handled by the regulator API.

I agree, this sounds like a GPIO that the driver should be understanding
directly to me.

--WfZ7S8PLGjBY9Voh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSbxBWAAoJELSic+t+oim9OnIQAILP4+u0yOy43NV8KK9USROC
7wUy2+YEkaMlbhhXvevCaK7dhqFAmmj9RZPWKcOfZn2IAIQGqkalKfizqgEVvCi7
CH9VrZ92LlFgp0Nlln4xI17IOzki5pILLGWx2dJZzCnXLCqyH8IYgdXM7sooHSVS
xLhu9JF6nqx5mRU3TuGBkZddW+JBzPnOwGAuTS+tZdI2RrBLJbLeCjJKpYQnizRP
ok+PjAQl1gduS8ycLDLhgy0a0vr6uW0ER8jUFC2uFxDn4APusi7Z1VSfg72ugpw5
/R3Z3Bfaj2uVS8phCbASyQu2k0BsocF2G45LSGrMM/dUvtaR5AGriuqWc24diJur
/xvzS70IFWkMzwuGTkO67kPQySkMZSwaQ56pzoqE51tV1R2yrBzPo2qWdtzXcrQX
JEP2L4144SmjlkkDOYVME5ccFSG5kpI7qlssjG6dz52ik9sKOtIKvr19ap0PukYg
Jm6WFoqNyco3sibEdJI9lfOXSHTemfTVNoLnRsARHoA20RDkxBxAqr+CKVi0axJF
QkFMyQQg4jyUIFp7m4RVM3t04hrJjw2o5juPh0tqUIYtE1iU0SAxNJ6gCKpTva2N
TDwdQUBf5rd/ln6NsJYqpCCUe9+kxB6jgCYx8PPqp+C+tfjbCvt1qnFX8pJJ+P1k
8vCuursNrJWXmYEfx8L4
=V5WW
-----END PGP SIGNATURE-----

--WfZ7S8PLGjBY9Voh--
