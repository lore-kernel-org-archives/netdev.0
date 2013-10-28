From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH 2/4] wl1251: move power GPIO handling into the driver
Date: Mon, 28 Oct 2013 12:23:54 -0700
Message-ID: <20131028192354.GA18208@sirena.org.uk>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
 <1382890469-25286-3-git-send-email-sre@debian.org>
 <1382891056.102746625@f315.i.mail.ru>
 <20131027201218.GA4414@earth.universe>
 <CANOLnONKcC1i19ypb4rh2Rff3WsVhhuUhNvZvYwDV2-ZNtjVxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vkogqOf2sHV7VnPd"
Cc: Alexander Shiyan <shc_work@mail.ru>,
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
	"linux-arm-kernel@lists.infradead.org"
To: Grazvydas Ignotas <notasas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassiel.sirena.org.uk ([80.68.93.111]:60812 "EHLO
	cassiel.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755810Ab3J1TYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 15:24:39 -0400
Content-Disposition: inline
In-Reply-To: <CANOLnONKcC1i19ypb4rh2Rff3WsVhhuUhNvZvYwDV2-ZNtjVxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Oct 28, 2013 at 07:29:52PM +0200, Grazvydas Ignotas wrote:

> When wl12xx family of chips is connected through SDIO, we already have
> that pin set up as a regulator controlled with the help of mmc
> subsystem. When time comes to communicate with the chip, mmc subsystem
> sees this as yet another SD card and looks for associated regulator
> for it, and the board file has that set up as a fixed regulator
> controlling that pin (see pandora_vmmc3 in
> arch/arm/mach-omap2/board-omap3pandora.c). To prevent poweroff after
> first SDIO communications are over, pm_runtime calls are used in
> drivers/net/wireless/ti/wl1251/sdio.c .

Is this actually controlling VMMC though, or is it some other control?
If it's not controlling VMMC then it shouldn't say that it is.

> I don't know if something similar can be done done in SPI case, but
> I'm sure this is not the first your-so-called regulator misuse.

It's not the first but that doesn't make controlling something other
than a regulator through the regulator API any less broken.

--vkogqOf2sHV7VnPd
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJSbrnBAAoJELSic+t+oim9zIwQAIvaD4m/WxkD0sxXd8pb5lKQ
Y88rGx5PwOI7AnVd1e+dHdv/EUrdhYQd7GpUC3YQ5aARR5BqKJhkw4woTuhKAdTl
vOMq2FFzXIEeLpwt7zoSu4naXGz+X2WYlSPOs8itze448Y5m5abFWI1433IEAD2C
MdMkaL6C+rLpzFYk5dGRsgK0efCc0jWgoJUmLnhCQH2UDOvCAVqL0HMzbe3TvnOE
BDrnyvti2XH/B708MVxRWjsNdxwcwD6PvjSSviSL/x57fjgs97NG3qDfuICSy4Vl
zcimUlnIaJXkLvA7tS+c5CcNS2MsJAoi3FiufQVmRAtK42CKLMrDEudKkeacSvmn
wd6yAZUh9MqHsLJj48OeWPzD4EMq3MVhlDUsHeCiI6OcEdoPTgEu2rQiPYN4Ihd2
UawXig1687VV6SgCkERjrW4oPA8GIu0lR/y4T/Po34UhhthVBGBE1xkc4ER8JDrt
WxxVQXKwFLke2J7qbMd1ngGyHCShLaw2aKhwuxJyOl+J09LgXtY4WH8vpp/ruY8m
0Ncsy88BKliO6AXnYqW648oP2axHnt/2uiw10wLjmk33RT0a4qrxeQsGF4YK0I4e
yrytIfz+kzLO1i/fdtvonRJvbLMLFG4514s6NTwa6l5olSzDc719BZsY4Q33u6kk
V+RxybJIeUSgZ5Zfb8Pa
=YWan
-----END PGP SIGNATURE-----

--vkogqOf2sHV7VnPd--
