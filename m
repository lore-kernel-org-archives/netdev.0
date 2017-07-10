From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 2/2] ARM: shmobile: defconfig: Enable Ethernet AVB
Date: Mon, 10 Jul 2017 10:38:47 +0200
Message-ID: <20170710083847.GH13680@verge.net.au>
References: <afcd181c-c805-8f3c-955f-652d001a03d4@cogentembedded.com>
 <1499270189-29945-1-git-send-email-biju.das@bp.renesas.com>
 <1499270189-29945-3-git-send-email-biju.das@bp.renesas.com>
 <12c32eee-8e4d-457e-97d7-625a5c63ad59@cogentembedded.com>
 <TY1PR06MB07020F58F15C964FC1AA1D22B7D50@TY1PR06MB0702.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Biju Das <biju.das@bp.renesas.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Magnus Damm <magnus.damm@gmail.com>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-renesas-soc@vger.kernel.org"
        <linux-renesas-soc@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chris Paterson <Chris.Paterson2@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59955 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752531AbdGJIiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 04:38:52 -0400
Content-Disposition: inline
In-Reply-To: <TY1PR06MB07020F58F15C964FC1AA1D22B7D50@TY1PR06MB0702.apcprd06.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 06, 2017 at 08:05:43AM +0000, Chris Paterson wrote:
> Hello Sergei, 
> 
> Thank you for your comments.
> 
> > From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> > Sent: 05 July 2017 17:14
> > 
> > Hello!
> > 
> > On 07/05/2017 06:56 PM, Biju Das wrote:
> > 
> > > The iWave RZ/G1M Q7 SOM supports Gigabit Ethernet Phy (Micrel
> > KSZ9031MNX).
> > > Gigabit Ethernet support is available in Renesas AVB driver.
> > > To increase hardware support enable the driver in the
> > > shmobile_defconfig multiplatform configuration.
> > >
> > > Signed-off-by: Biju Das <biju.das@bp.renesas.com>
> > > Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>
> > > Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>
> > > ---
> > >  arch/arm/configs/shmobile_defconfig | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/arch/arm/configs/shmobile_defconfig
> > > b/arch/arm/configs/shmobile_defconfig
> > > index 3c66a42..d992911 100644
> > > --- a/arch/arm/configs/shmobile_defconfig
> > > +++ b/arch/arm/configs/shmobile_defconfig
> > > @@ -83,6 +83,7 @@ CONFIG_NETDEVICES=y
> > >  # CONFIG_NET_VENDOR_MICREL is not set  #
> > CONFIG_NET_VENDOR_NATSEMI is
> > > not set  CONFIG_SH_ETH=y
> > > +CONFIG_RAVB=y
> > 
> >     Hm, I would enable it only as a module, given it's not easy to make use of
> > AVB on the 32-bit boards.
> 
> On the iWave-M platforms the only available Ethernet interface is AVB.
> Without including the RAVB driver in the Kernel we won't be able to use
> NFS.
> 
> I know adding CONFIG_RAVB for all shmobile devices may increase the
> Kernel size for everyone, especially when most cannot use AVB without an
> add-on board, but I don't think the increase will be big.

Thanks for the explanation, applied for v4.14.
