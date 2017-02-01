From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the DP83867
 TI's PHY driver
Date: Wed, 1 Feb 2017 22:14:40 +0100
Message-ID: <20170201211440.GG7395@lunn.ch>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
 <20170201171610.GC7395@lunn.ch>
 <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
 <20170201220500.29d478aa@jawa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        devicetree@vger.kernel.org
To: Lukasz Majewski <lukma@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170201220500.29d478aa@jawa>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We would need a tri-state device tree properly:
> 
> 1. Not defined - do nothing
> 2. Defined as 0 -> explicitly disable port mirroring
> 3. Defined as 1 -> explicitly enable port mirriring
> 
> The "net-phy-lane-swap" only fulfills points 1 and 3 above.
> 
> In my use case I do need point 2.

Looking at the datasheet, PORT_MIRROR_EN defaults to 0. So it seems
reasonable to unconditionally set it to 0 when the PHY driver
loads. Any device which needs a value of 1 can set "net-phy-lane-swap"

       Andrew
