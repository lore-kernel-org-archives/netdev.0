From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v5 02/10] net: pxa168_eth: add device tree support
Date: Tue, 30 Sep 2014 16:28:50 +0200
Message-ID: <20140930142850.GA30288@kwain>
References: <1411742036-23520-1-git-send-email-antoine.tenart@free-electrons.com>
 <1411742036-23520-3-git-send-email-antoine.tenart@free-electrons.com>
 <20140929.160436.1932620234954504510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: antoine.tenart@free-electrons.com, sebastian.hesselbarth@gmail.com,
	alexandre.belloni@free-electrons.com,
	thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
	jszhang@marvell.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140929.160436.1932620234954504510.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

On Mon, Sep 29, 2014 at 04:04:36PM -0400, David Miller wrote:
> From: Antoine Tenart <antoine.tenart@free-electrons.com>
> Date: Fri, 26 Sep 2014 16:33:48 +0200
>=20
> > @@ -1603,6 +1620,12 @@ static int pxa168_eth_suspend(struct platfor=
m_device *pdev, pm_message_t state)
> >  #define pxa168_eth_suspend NULL
> >  #endif
> > =20
> > +static const struct of_device_id pxa168_eth_of_match[] =3D {
> > +	{ .compatible =3D "marvell,pxa168-eth" },
> > +	{ },
> > +};
> > +MODULE_DEVICE_TABLE(of, pxa168_eth_of_match)
> > +
> >  static struct platform_driver pxa168_eth_driver =3D {
>=20
> You didn't even compile test this change with module support enabled.
>=20
> drivers/net/ethernet/marvell/pxa168_eth.c:1670:1: error: expected =E2=
=80=98,=E2=80=99 or =E2=80=98;=E2=80=99 before =E2=80=98static=E2=80=99
>=20
> MODULE_DEVICE_TABLE() must be completed with a trailing ';'

Oops, thanks for spotting this!

Antoine

--=20
Antoine T=C3=A9nart, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
