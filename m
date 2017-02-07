From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/3] net: phy: dp83867: Add lane swapping support in
 the DP83867 TI's PHY driver
Date: Tue, 07 Feb 2017 13:59:46 -0500 (EST)
Message-ID: <20170207.135946.1622253517853357858.davem@davemloft.net>
References: <1486444824-12733-1-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, m-karicheri2@ti.com,
        linux-kernel@vger.kernel.org, eric@engestrom.ch, andrew@lunn.ch,
        netdev@vger.kernel.org, kishon@ti.com, grygorii.strashko@ti.com
To: lukma@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486444824-12733-1-git-send-email-lukma@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lukasz Majewski <lukma@denx.de>
Date: Tue,  7 Feb 2017 06:20:23 +0100

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

Applied.
