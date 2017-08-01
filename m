From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 00/11] net: dsa: rework EEE support
Date: Tue, 1 Aug 2017 16:31:13 +0200
Message-ID: <20170801143113.GF23157@lunn.ch>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 06:17:08PM -0400, Vivien Didelot wrote:
> EEE implies configuring the port's PHY and MAC of both ends of the wire.
> 
> The current EEE support in DSA mixes PHY and MAC configuration, which is
> bad because PHYs must be configured through a proper PHY driver. The DSA
> switch operations for EEE are only meant for configuring the port's MAC,
> which are integrated in the Ethernet switch device.
> 
> This patchset fixes the EEE support in qca8k driver, makes the DSA layer
> call phy_init_eee for all drivers, and remove the EEE support from the
> mv88e6xxx driver since the Marvell PHY driver should be enough for it.

Hi Vivien

Thanks for working on this. I like the general direction this takes,
moving the repeated code into slave.c

       Andrew
