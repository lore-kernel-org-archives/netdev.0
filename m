From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH 0/2] ARM: am335x-icev2: Add ethernet support
Date: Thu, 30 Mar 2017 15:35:25 +0300
Message-ID: <178a255a-5e26-fe6f-8d9e-a7755f0b5fca@ti.com>
References: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <grygorii.strashko@ti.com>, <nsekhar@ti.com>, <jsarha@ti.com>,
        <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489412554-2054-1-git-send-email-rogerq@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tony & Dave,

On 13/03/17 15:42, Roger Quadros wrote:
> Hi,
> 
> This series adds ethernet support to am335x-icev2 board.
> 
> The ethernet PHYs on the board need an explicit GPIO reset pulse
> to ensure they bootstrap to the correct mode. Without the
> GPIO reset they just don't work.
> 
> cheers,
> -roger

Any comments on this series. Patch 1 is at version 2.

> 
> Roger Quadros (2):
>   net: davinci_mdio: add GPIO reset logic
>   ARM: dts: am335x-icev2: Add CPSW ethernet0 and ethernet1
> 
>  .../devicetree/bindings/net/davinci-mdio.txt       |   2 +
>  arch/arm/boot/dts/am335x-icev2.dts                 | 113 +++++++++++++++++++++
>  drivers/net/ethernet/ti/davinci_mdio.c             |  68 +++++++++++--
>  3 files changed, 175 insertions(+), 8 deletions(-)
> 

cheers,
-roger
