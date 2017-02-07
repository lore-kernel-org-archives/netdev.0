From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 2/3] net: phy: dp83867: Add lane swapping support in
 the DP83867 TI's PHY driver
Date: Tue, 7 Feb 2017 14:00:31 +0100
Message-ID: <20170207130031.GA31560@lunn.ch>
References: <1486444824-12733-1-git-send-email-lukma@denx.de>
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
In-Reply-To: <1486444824-12733-1-git-send-email-lukma@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 06:20:23AM +0100, Lukasz Majewski wrote:
> This patch adds support for enabling or disabling the lane swapping (called
> "port mirroring" in PHY's CFG4 register) feature of the DP83867 TI's PHY
> device.
> 
> One use case is when bootstrap configuration enables this feature (because
> of e.g. LED_0 wrong wiring) so then one needs to disable it in software
> (at u-boot/Linux).
> 
> Signed-off-by: Lukasz Majewski <lukma@denx.de>
> ---
> Changes for v3:
> - Add "line swapping" to the patch description
> - Add DP83867_PORT_MIRROING_KEEP enum for better code readability
> 
> Changes for v2:
> - use "net-phy-lane-swap" and "net-phy-lane-no-swap" generic PHY properties.
>   instead of TI specific one
> ---
>  drivers/net/phy/dp83867.c | 38 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 38 insertions(+)

Hi Lukasz

You are missing the documentation update. Documentation/devicetree/binding/net/phy.h

Apart from that, this looks good.

Thanks
  Andrew
