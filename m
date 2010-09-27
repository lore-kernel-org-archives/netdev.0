From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Sep 2010 14:44:46 -0400
Message-ID: <20100927184445.GF11086@tuxdriver.com>
References: <20100927154408.55a28127.sfr@canb.auug.org.au>
 <AANLkTinHk82jM7Ztwb1aB1xb-hSLeg5Hb07mhYCaeszi@mail.gmail.com>
 <20100927180412.GD11086@tuxdriver.com>
 <20100927.111818.149846920.davem@davemloft.net>
 <20100927182546.GE11086@tuxdriver.com>
 <AANLkTi=YHhRWFix1QDuEnRW7r_UaNtp6KSL9uLdUzdqM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTi=YHhRWFix1QDuEnRW7r_UaNtp6KSL9uLdUzdqM@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 08:38:50PM +0200, Ohad Ben-Cohen wrote:
> On Mon, Sep 27, 2010 at 8:25 PM, John W. Linville
> <linville@tuxdriver.com> wrote:
> >> BTW, if this fuglet going to work if the driver is built modular?
> >>
> >> The idea of this things seems to be to allow arch platform code to=
 call
> >> into it to set things. =A0Such calls from arch platform code are g=
oing
> >> to be "obj-y"
> >>
> >> So if this is built into the modular driver, I can't see how it
> >> can work.
> >
> > Dave is right -- these Kconfig dependencies (or lack thereof) seem
> > to be wrong.
>=20
> This is why I had to put it in drivers/net/wireless/Makefile (in both
> the original patch and in the fix I sent earlier) and not in
> drivers/net/wireless/wl12xx/Makefile (as it was in the fix that Dave
> was referring to).
>=20
> This way it works with a modular driver.

That doesn't seem very helpful if someone selects

CONFIG_MACH_OMAP_ZOOM2=3Dy
CONFIG_WL12XX_PLATFORM_DATA=3Dn

or am I missing something?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
