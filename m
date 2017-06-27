From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Tue, 27 Jun 2017 16:52:16 +0200
Message-ID: <20170627145216.GE9921@lunn.ch>
References: <1498192929-7519-1-git-send-email-david.wu@rock-chips.com>
 <1498193947-8011-1-git-send-email-david.wu@rock-chips.com>
 <3788bbae-c99c-b63e-8910-f98567124cac@gmail.com>
 <1f8255c9-14c1-440f-0f0c-d173ed439d8d@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        heiko@sntech.de, robh+dt@kernel.org, mark.rutland@arm.com,
        catalin.marinas@arm.com, will.deacon@arm.com, olof@lixom.net,
        linux@armlinux.org.uk, arnd@arndb.de, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, huangtao@rock-chips.com,
        hwg@rock-chips.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David.Wu" <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1f8255c9-14c1-440f-0f0c-d173ed439d8d@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'm a little confused for the property of phy-mode = "internal".
> If the property of phy-mode is configured as "internal" from DT , i
> could not get the rmii or rgmii mode for the phy.
> I use it to differentiate rmii or rgmii for different configuration.

phy-mode is about the bus between the MAC and the PHY. Internal means
there is not a standard bus between the MAC and the PHY, something
proprietary is being used to embed the PHY in the MAC.

If you are using RMII or RGMII, then it is not internal, in that as
standard bus is being used. It does not matter if that bus is not
available external to the SoC, it still exists.

	  Andrew
