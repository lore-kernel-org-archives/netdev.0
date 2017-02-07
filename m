From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 3/3] net: phy: dp83867: Recover from "port mirroring"
 N/A MODE4
Date: Tue, 7 Feb 2017 14:04:00 +0100
Message-ID: <20170207130400.GD31560@lunn.ch>
References: <1486444824-12733-1-git-send-email-lukma@denx.de>
 <1486444824-12733-2-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Lukasz Majewski <lukma@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1486444824-12733-2-git-send-email-lukma@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 06:20:24AM +0100, Lukasz Majewski wrote:
> The DP83867 when not properly bootstrapped - especially with LED_0 pin -
> can enter N/A MODE4 for "port mirroring" feature.
> 
> To provide normal operation of the PHY, one needs not only to explicitly
> disable the port mirroring feature, but as well stop some IC internal
> testing (which disables RGMII communication).
> 
> To do that the STRAP_STS1 (0x006E) register must be read and RESERVED bit
> 11 examined. When it is set, the another RESERVED bit (11) at PHYCR
> (0x0010) register must be clear to disable testing mode and enable RGMII
> communication.
> 
> Thorough explanation of the problem can be found at following e2e thread:
> "DP83867IR: Problem with RESERVED bits in PHY Control Register (PHYCR) -
> Linux driver"
> 
> https://e2e.ti.com/support/interface/ethernet/f/903/p/571313/2096954#2096954
> 
> Signed-off-by: Lukasz Majewski <lukma@denx.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
