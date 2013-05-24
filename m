From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCHv3 1/6] net: Add EMAC ethernet driver found on Allwinner
 A10 SoC's
Date: Fri, 24 May 2013 22:10:30 +0200
Message-ID: <20130524201030.GA17847@lukather>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com>
 <1369387394-9453-2-git-send-email-maxime.ripard@free-electrons.com>
 <519F6128.9060608@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com
To: Emilio =?iso-8859-1?Q?L=F3pez?= <emilio@elopez.com.ar>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <519F6128.9060608@elopez.com.ar>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Emilio,

On Fri, May 24, 2013 at 09:46:32AM -0300, Emilio L=F3pez wrote:
> El 24/05/13 06:23, Maxime Ripard escribi=F3:
> > From: Stefan Roese <sr@denx.de>
> >=20
> > The Allwinner A10 has an ethernet controller that seem to be develo=
pped
> > internally by them.
> >=20
> > The exact feature set of this controller is unknown, since there is=
 no
> > public documentation for this IP, and this driver is mostly the one
> > published by Allwinner that has been heavily cleaned up.
> >=20
> > Signed-off-by: Stefan Roese <sr@denx.de>
> > Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> > ---
>=20
> (snip)
>=20
> > +
> > +config SUN4I_EMAC
> > +        tristate "Allwinner A10 EMAC support"
> > +	depends on ARCH_SUNXI
> > +	depends on OF
> > +	select CRC32
> > +	select NET_CORE
> > +	select MII
> > +	select REGULATOR_FIXED_VOLTAGE
> > +        ---help---
> > +          Support for Allwinner A10 EMAC ethernet driver.
> > +
> > +          To compile this driver as a module, choose M here.  The =
module
> > +          will be called sun4i-emac.
> > +
>=20
> You also need to select REGULATOR when you select REGULATOR_FIXED_VOL=
TAGE

Actually, this should be in patch 2/6.

Thanks for noticing!

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
