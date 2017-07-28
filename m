From: "David.Wu" <david.wu@rock-chips.com>
Subject: Re: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Fri, 28 Jul 2017 14:46:25 +0800
Message-ID: <7764adcf-02c5-5ae1-1735-7f7e36790c30@rock-chips.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
 <20170727134834.GD18666@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, heiko@sntech.de, f.fainelli@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk,
        arnd@arndb.de, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170727134834.GD18666@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

ÔÚ 2017/7/27 21:48, Andrew Lunn Ð´µÀ:
> I think we need to discuss this. This PHY appears to be on an MDIO
> bus, it uses a standard PHY driver, and it appears to be using an RMII
> interface. So it is just an ordinary PHY.
> 
> Internal is supposed to be something which is not ordinary, does not
> use one of the standard phy modes, needs something special to make it
> work.

Yes, it is a ordinary PHY in fact, using MDIO bus, but it is a internal 
phy inside Soc, so the "internal" is not the internal as Florain said.
