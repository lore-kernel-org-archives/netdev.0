From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 01/11] net: phy: Add rockchip phy driver support
Date: Sat, 24 Jun 2017 04:10:52 +0200
Message-ID: <20170624021052.GA4875@lunn.ch>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1498192929-7519-2-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +
> +static int internal_config_init(struct phy_device *phydev)
> +{

internal_ is a bit generic. The Marvell Ethernet switches have
internal phy, etc. rockchip_ would be a better prefix.

	 Andrew
