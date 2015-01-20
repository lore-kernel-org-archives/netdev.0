From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH net-next 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb board
 enet phy address
Date: Tue, 20 Jan 2015 08:44:09 +0000
Message-ID: <BLUPR03MB3732D6601E8D5F5CD12D348F54B0@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1421660282-29494-1-git-send-email-b38611@freescale.com>
 <20150120083156.GY2766@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"s.hauer@pengutronix.de" <s.hauer@pengutronix.de>,
	"stefan@agner.ch" <stefan@agner.ch>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0108.outbound.protection.outlook.com ([157.56.110.108]:33634
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751356AbbATIoM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:44:12 -0500
In-Reply-To: <20150120083156.GY2766@dragon>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@linaro.org> Sent: Tuesday, January 20, 2015 4:32 PM
> To: Duan Fugang-B38611
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-arm-
> kernel@lists.infradead.org; s.hauer@pengutronix.de; stefan@agner.ch
> Subject: Re: [PATCH net-next 1/1] ARM: dts: imx6sx: correct i.MX6sx sdb
> board enet phy address
> 
> On Mon, Jan 19, 2015 at 05:38:02PM +0800, Fugang Duan wrote:
> > The commit (3d125f9c91c5) cause i.MX6SX sdb enet cannot work. The
> > cause is the commit add mdio node with un-correct phy address.
> >
> > The patch just correct i.MX6sx sdb board enet phy address.
> >
> > Signed-off-by: Fugang Duan <B38611@freescale.com>
> > ---
> >  arch/arm/boot/dts/imx6sx-sdb.dts |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/arch/arm/boot/dts/imx6sx-sdb.dts
> > b/arch/arm/boot/dts/imx6sx-sdb.dts
> > index 8c1febd..9db123f 100644
> > --- a/arch/arm/boot/dts/imx6sx-sdb.dts
> > +++ b/arch/arm/boot/dts/imx6sx-sdb.dts
> > @@ -167,11 +167,11 @@
> >  		#size-cells = <0>;
> >
> >  		ethphy1: ethernet-phy@0 {
> 
> The unit-address should match 'reg' property, so it needs an update too.
> 
> Shawn

Yes, you are right.
I update it and send the next version.

Thanks,
Andy
