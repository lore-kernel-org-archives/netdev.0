From: Sebastian Reichel <sre@kernel.org>
Subject: Re: [RFC 11/15] power: reset: keystone: Add missing MFD_SYSCON
 dependency on HAS_IOMEM
Date: Thu, 3 Mar 2016 13:33:43 +0100
Message-ID: <20160303123343.GB5687@earth>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
 <1456992221-26712-12-git-send-email-k.kozlowski@samsung.com>
 <5230562.E0gg2SNP0m@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3914293735902179018=="
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-samsun@comu.ring0.de,
 David Brown <david.brown@linaro.org>,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Lee Jones <lee.jones@linaro.org>, Thomas Gleixner <tglx@linutronix.de>,
 devel@driverdev.osuosl.org, Vinod Koul <vinod.koul@intel.com>,
 Daniel Lezcano <daniel.lezcano@linaro.org>,
 Kishon Vijay Abraham I <kishon@ti.com>, Andy Gross <andy.gross@linaro.org>,
 linux-media@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
 rtc-linux@googlegroups.com, Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
 Marc Zyngier <marc.zyngier@arm.com>, linux-arm-msm@vger.kernel.org,
 linux-gpio@vger.kernel.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 Dan Williams <dan.j.williams@intel.com>, linux-soc@vger.kernel.org,
 linux-ar
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <5230562.E0gg2SNP0m@wuerfel>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


--===============3914293735902179018==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ZfOjI3PrQbgiZnxM"
Content-Disposition: inline


--ZfOjI3PrQbgiZnxM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Mar 03, 2016 at 12:00:14PM +0100, Arnd Bergmann wrote:
> On Thursday 03 March 2016 17:03:37 Krzysztof Kozlowski wrote:
> > diff --git a/drivers/power/reset/Kconfig b/drivers/power/reset/Kconfig
> > index 0a6408a39c66..0f34846ae80d 100644
> > --- a/drivers/power/reset/Kconfig
> > +++ b/drivers/power/reset/Kconfig
> > @@ -141,6 +141,7 @@ config POWER_RESET_XGENE
> >  config POWER_RESET_KEYSTONE
> >         bool "Keystone reset driver"
> >         depends on ARCH_KEYSTONE
> > +       depends on HAS_IOMEM    # For MFD_SYSCON
> >         select MFD_SYSCON
> >         help
> >           Reboot support for the KEYSTONE SoCs.
> >=20
>=20
> This is platform specific, but we should probably add || COMPILE_TEST
> along with the HAS_IOMEM dependency.

Sounds sensible. Will you guys send an updated patch?

-- Sebastian

--ZfOjI3PrQbgiZnxM
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJW2C8kAAoJENju1/PIO/qanpwP+gJywD4VE/gT2ZagnJwhE8Em
JgZwSnA2KU0yEoOurmOEgsRBCIlaPXwmYe9tO/9vQ8akB9wuNKoxMHOda16G6894
PsRCgyloYocmcC1MFVp6oioPryISIP0Ik71pAkvqL35HZupN715sCynWvQsTY9nN
gPR7sTbfDv7OT1sHdU8qOkacJgHglCYlbtoaOvVzF16A4G35wCXAH5WqQyQ6kbOv
X8SyBARnrW3P/qyUe5jlGw1DLZYi4VsMi16JE1btxFCQNXN0zu848LHAK2xvwhqK
Yy+TKxGP6l45RKin/p/zAv6ThZ29nLvo8E2PP6CX4Ed1qKWQWEt8q32sf8lDdFhB
PKF7hOEmoFRojO/YZ1sKZSMg7BEwTYliAT8fmWohi4mnKJgsywJKYgwr831Zs1RR
UepUK0XGsyF/BgymLiqAmoRjHphpXzykY4mnCo1/sNdM4kzkvnb4zwu4+QcQRSJW
CTrGxrvZ66YND4vWGHFiglNJ3SNdgVLY//iFkXWXyNYnlvk1o6A4bwWmCHXynew8
aWr6lbqqpEYD1EF2JvbXkPqvCogH6enSjy2cb17SSXT/Ua87jOfsv+/s4DP0+ZM/
izsOe6ao6pwn5ZZ5NY1k+5M9MDNbpmmr9lXfoSvm7E4TkcJzxWMDYgodmtgOpbmJ
FDmyIoussJMr/fnkKPhf
=hIFl
-----END PGP SIGNATURE-----

--ZfOjI3PrQbgiZnxM--

--===============3914293735902179018==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============3914293735902179018==--
