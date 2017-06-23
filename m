From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Fri, 23 Jun 2017 15:55:45 +0200
Message-ID: <20170623135545.GB21943@lunn.ch>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de,
        f.fainelli@gmail.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32969 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752066AbdFWN4P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 09:56:15 -0400
Content-Disposition: inline
In-Reply-To: <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 23, 2017 at 12:41:59PM +0800, David Wu wrote:
> Support internal ephy currently.
> 
> Signed-off-by: David Wu <david.wu@rock-chips.com>
> ---
>  drivers/net/phy/Kconfig    |  4 ++
>  drivers/net/phy/Makefile   |  1 +
>  drivers/net/phy/rockchip.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 99 insertions(+)
>  create mode 100644 drivers/net/phy/rockchip.c
> 
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index c360dd6..86010d4 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -350,6 +350,10 @@ config XILINX_GMII2RGMII
>           the Reduced Gigabit Media Independent Interface(RGMII) between
>           Ethernet physical media devices and the Gigabit Ethernet controller.
>  
> +config ROCKCHIP_MAC_PHY
> +	tristate "Drivers for ROCKCHIP MAC PHY"
> +	---help---
> +	  Currently supports the mac internal ephy.
>  endif # PHYLIB

Alphabetic order please for Kconfig and Makefile.

I will review the rest later today/tomorrow.

  Andrew
