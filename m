From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 0/2] ARM: am335x-icev2: Add ethernet support
Date: Tue, 4 Apr 2017 09:01:06 -0700
Message-ID: <20170404160106.GR10760@atomide.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
 <178a255a-5e26-fe6f-8d9e-a7755f0b5fca@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, grygorii.strashko@ti.com, nsekhar@ti.com,
        jsarha@ti.com, linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <178a255a-5e26-fe6f-8d9e-a7755f0b5fca@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Roger Quadros <rogerq@ti.com> [170330 05:37]:
> Hi Tony & Dave,
> 
> On 13/03/17 15:42, Roger Quadros wrote:
> > Hi,
> > 
> > This series adds ethernet support to am335x-icev2 board.
> > 
> > The ethernet PHYs on the board need an explicit GPIO reset pulse
> > to ensure they bootstrap to the correct mode. Without the
> > GPIO reset they just don't work.
> > 
> > cheers,
> > -roger
> 
> Any comments on this series. Patch 1 is at version 2.

I think you meant patch 2/3 is at version2. I've picked
patches 2 and 3 for v4.12 into dt and defconfig branches.

You may need to resend the davinci_mdio.c patch alone
for Dave as he usually won't pick individual patches I
think.

Regards,

Tony

> > Roger Quadros (2):
> >   net: davinci_mdio: add GPIO reset logic
> >   ARM: dts: am335x-icev2: Add CPSW ethernet0 and ethernet1
> > 
> >  .../devicetree/bindings/net/davinci-mdio.txt       |   2 +
> >  arch/arm/boot/dts/am335x-icev2.dts                 | 113 +++++++++++++++++++++
> >  drivers/net/ethernet/ti/davinci_mdio.c             |  68 +++++++++++--
> >  3 files changed, 175 insertions(+), 8 deletions(-)
> > 
> 
> cheers,
> -roger
