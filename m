From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethtool: remove error check for legacy setting
 transceiver type
Date: Sun, 22 Oct 2017 02:15:14 +0100 (WEST)
Message-ID: <20171022.021514.303896603307493322.davem@davemloft.net>
References: <20171019233208.15444-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, geert@linux-m68k.org,
        renjith.rv@quest-global.com
To: niklas.soderlund+renesas@ragnatech.se
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <20171019233208.15444-1-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
Date: Fri, 20 Oct 2017 01:32:08 +0200

> Commit 9cab88726929605 ("net: ethtool: Add back transceiver type")
> restores the transceiver type to struct ethtool_link_settings and
> convert_link_ksettings_to_legacy_settings() but forgets to remove the
> error check for the same in convert_legacy_settings_to_link_ksettings().
> This prevents older versions of ethtool to change link settings.
> 
>     # ethtool --version
>     ethtool version 3.16
> 
>     # ethtool -s eth0 autoneg on speed 100 duplex full
>     Cannot set new settings: Invalid argument
>       not setting speed
>       not setting duplex
>       not setting autoneg
> 
> While newer versions of ethtool works.
> 
>     # ethtool --version
>     ethtool version 4.10
> 
>     # ethtool -s eth0 autoneg on speed 100 duplex full
>     [   57.703268] sh-eth ee700000.ethernet eth0: Link is Down
>     [   59.618227] sh-eth ee700000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
> 
> Fixes: 19cab88726929605 ("net: ethtool: Add back transceiver type")
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

Applied.
