From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH v5 00/20] net-next: stmmac: add dwmac-sun8i ethernet
 driver
Date: Mon, 1 May 2017 17:58:56 +0200
Message-ID: <20170501155856.GA1957@Red>
References: <20170501124520.3769-1-clabbe.montjoie@gmail.com>
 <20170501140133.GD31281@lunn.ch>
 <CAGb2v67qGqswdz_JcDaD5jTkcvtBuzqqP8KZh=S_5pkp=o6cUQ@mail.gmail.com>
 <20170501144541.GB1285@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chen-Yu Tsai <wens@csie.org>, Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, devicetree <devicetree@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
        netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35925 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758420AbdEAP7C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 11:59:02 -0400
Content-Disposition: inline
In-Reply-To: <20170501144541.GB1285@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 04:45:41PM +0200, Andrew Lunn wrote:
> On Mon, May 01, 2017 at 10:28:46PM +0800, Chen-Yu Tsai wrote:
> > On Mon, May 1, 2017 at 10:01 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > > On Mon, May 01, 2017 at 02:45:00PM +0200, Corentin Labbe wrote:
> > >> Hello
> > >>
> > >> This patch series add the driver for dwmac-sun8i which handle the Ethernet MAC
> > >> present on Allwinner H3/H5/A83T/A64 SoCs.
> > >>
> > >> This driver is the continuation of the sun8i-emac driver.
> > >> During the development, it appeared that in fact the hardware was a modified
> > >> version of some dwmac.
> > >> So the driver is now written as a glue driver for stmmac.
> > >>
> > >> It supports 10/100/1000 Mbit/s speed with half/full duplex.
> > >> It can use an internal PHY (MII 10/100) or an external PHY
> > >> via RGMII/RMII.
> > >
> > > Hi Corentin
> > >
> > > Sorry if this has been asked before....
> > >
> > > Does the internal PHY have a phy driver? It seems like
> > > tx-delay-ps/rx-delay-ps are properties of this internal PHY, and so
> > > should be in the phy driver, if it has one.
> > 
> > Nope. These affect the delay lines for the external PHY interface.

I will add some sentences in the documentation to be more clear about that.

> 
> Oh, yes. I understood the patch wrong.
> 
> None of the patches actually use these properties. Are they actually
> needed? We should avoid adding vendor specific properties, if they are
> not used.
> 

The board that use it is the BananaPi M3, but the SoC A83T still lack clocks support.
So theses properties is already used out of tree, and will be used in tree soon.

Regards
