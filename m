From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Fri, 28 Jul 2017 14:56:03 +0800
Message-ID: <69ad9443-ff65-8e49-df68-7e5e6c812d45@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
 <20170727134834.GD18666@lunn.ch>
 <65ae1747-4dff-b1d8-8aa3-684fc8c7809a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, heiko@sntech.de, robh+dt@kernel.org,
        mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
        olof@lixom.net, linux@armlinux.org.uk, arnd@arndb.de,
        peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <65ae1747-4dff-b1d8-8aa3-684fc8c7809a@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

在 2017/7/28 0:54, Florian Fainelli 写道:
> - if you need knowledge about this PHY connection type prior to binding
> the PHY device and its driver (that is, before of_phy_connect()) we
> could add a boolean property e.g: "phy-is-internal" that allows us to
> know that, or we can have a new phy-mode value, e.g: "internal-rmii"
> which describes that, either way would probably be fine, but the former
> scales better
> 

Using "phy-is-internal" is very helpful, but it is easy to confuse with 
the real internal PHY, may we use the other words like phy is inlined🙂.

> Then again, using phy-mode = "internal" even though this is Reduced MII
> is not big of a deal IMHO as long as there is no loss of information and
> that internal de-facto means internal reduced MII for instance.
> -- 
