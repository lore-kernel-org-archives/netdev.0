From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: dp83867: Port mirroring support in the DP83867
 TI's PHY driver
Date: Thu, 2 Feb 2017 14:11:12 +0100
Message-ID: <20170202131112.GI4967@lunn.ch>
References: <1485960215-5148-1-git-send-email-lukma@denx.de>
 <20170201171610.GC7395@lunn.ch>
 <2f3766f0-42df-6aab-dda1-14022c57fb30@gmail.com>
 <20170201220500.29d478aa@jawa>
 <20170201211440.GG7395@lunn.ch>
 <20170201231323.732dd327@jawa>
 <20170202015416.GG4967@lunn.ch>
 <20170202101739.67e7e6b3@jawa>
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
In-Reply-To: <20170202101739.67e7e6b3@jawa>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The bootstrapping process in the PHY sets this bit. This is wrong since
> the board lane layout is not "swapped"
 
Ah, you mean a strapping pin? Resistor to ground/VCC?
That is a different matter. It makes it a lot less likely to break
some existing board with such a change.

> I have thought a bit about that and I think that we should define
> complementary "net-phy-lane-no-swap" as suggested by Florian. Then
> affected boards could define it and use.

This is the most flexible solution. Yes, that is O.K. for me.

     Andrew
