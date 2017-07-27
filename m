From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Thu, 27 Jul 2017 15:48:34 +0200
Message-ID: <20170727134834.GD18666@lunn.ch>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, f.fainelli@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk,
        arnd@arndb.de, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 27, 2017 at 09:02:16PM +0800, David Wu wrote:
> To make internal phy work, need to configure the phy_clock,
> phy cru_reset and related registers.
> 
> Signed-off-by: David Wu <david.wu@rock-chips.com>
> ---
> changes in v2:
>  - Use the standard "phy-mode" property for internal phy. (Florian)

I think we need to discuss this. This PHY appears to be on an MDIO
bus, it uses a standard PHY driver, and it appears to be using an RMII
interface. So it is just an ordinary PHY.

Internal is supposed to be something which is not ordinary, does not
use one of the standard phy modes, needs something special to make it
work.

Florain, it appears to be your suggestion to use internal. What do you
say?

	Andrew
