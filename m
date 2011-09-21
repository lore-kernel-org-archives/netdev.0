From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH v2 3/3] net/fec: add imx6q enet support
Date: Wed, 21 Sep 2011 19:28:43 +0800
Message-ID: <20110921112842.GE28907@S2100-06.ap.freescale.net>
References: <1316603432-20032-1-git-send-email-shawn.guo@linaro.org>
 <1316603432-20032-4-git-send-email-shawn.guo@linaro.org>
 <CAOMZO5CzVj=sMhD24H0OQKqp2Z0XtHhkTX=kEp5oshKqTAJ4oA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>, <patches@linaro.org>,
	<netdev@vger.kernel.org>,
	Troy Kisky <troy.kisky@boundarydevices.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@karo-electronics.de>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe002.messaging.microsoft.com ([213.199.154.205]:57364
	"EHLO AM1EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752486Ab1IULTO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Sep 2011 07:19:14 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5CzVj=sMhD24H0OQKqp2Z0XtHhkTX=kEp5oshKqTAJ4oA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2011 at 08:07:42AM -0300, Fabio Estevam wrote:
> On Wed, Sep 21, 2011 at 8:10 AM, Shawn Guo <shawn.guo@linaro.org> wro=
te:
> ...
> > diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/e=
thernet/freescale/Kconfig
> > index 4dbe41f..1cf6716 100644
> > --- a/drivers/net/ethernet/freescale/Kconfig
> > +++ b/drivers/net/ethernet/freescale/Kconfig
> > @@ -7,7 +7,7 @@ config NET_VENDOR_FREESCALE
> > =A0 =A0 =A0 =A0default y
> > =A0 =A0 =A0 =A0depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 |=
| PPC_MPC512x || \
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 M523x || M527x || M5272 || M528=
x || M520x || M532x || \
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IMX_HAVE_PLATFORM_FEC || MXS_H=
AVE_PLATFORM_FEC || \
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ARCH_MXC || ARCH_MXS || \
>=20
> Do you need to get rid of  IMX_HAVE_PLATFORM_FEC and MXS_HAVE_PLATFOR=
M_FEC?
>=20
Yes, I do.  We are moving to device tree, so the Kconfig symbol
IMX_HAVE_PLATFORM_FEC makes no sense any more, as the platform device
registration will be done by DT core according whether there is a FEC
node in device tree or not.

> By doing that you are selecting FEC for SoCs that don=B4t have this
> module such as MX1/MX21/MX31.
>=20
No.  By doing that, FEC will not be selected for any SoCs by default.
You need to select it explicitly if you are building a platform with
=46EC support.

--=20
Regards,
Shawn
