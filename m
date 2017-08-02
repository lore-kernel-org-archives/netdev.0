From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/11] net: dsa: rework EEE support
Date: Tue, 01 Aug 2017 20:09:56 -0700 (PDT)
Message-ID: <20170801.200956.2244963133644668921.davem@davemloft.net>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        john@phrozen.org
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue,  1 Aug 2017 16:32:30 -0400

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
> 
> Changes in v2:
>  - make PHY device and DSA EEE ops mandatory for slave EEE operations.
>  - simply return 0 in drivers which don't need to do anything to
>    configure the port' MAC. Subsequent PHY calls will be enough.

Series applied, thanks Vivien.
