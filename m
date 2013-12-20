From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH] can: ti_hecc: Use the OMAP2PLUS dependency for omap2plus
 devices
Date: Fri, 20 Dec 2013 09:52:37 -0300
Message-ID: <20131220125236.GA26648@localhost>
References: <1387542110-26596-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <52B439AE.7020304@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52B439AE.7020304@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 20, 2013 at 01:35:58PM +0100, Marc Kleine-Budde wrote:
> On 12/20/2013 01:21 PM, Ezequiel Garcia wrote:
> > OMAP's ti_hecc driver is used to support the CAN controller on many
> > omap2plus SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x).
> > Constrain the driver to OMAP2PLUS, which is the super-set of all th=
e
> > other SoCs variants.
>=20
> Why not enable it for all ARM platforms to get a bigger compile cover=
age?
>=20

Hm.. Isn't the COMPILE_TEST option for getting compile coverage?

If the IP is only available on OMAP SoCs, it makes sense to only allow
building it there, but I don't really have a strong opinion.
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
