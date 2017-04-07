From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v4 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Fri, 7 Apr 2017 21:37:16 +0200
Message-ID: <20170407193716.GC500@lunn.ch>
References: <1491554709-9723-1-git-send-email-sean.wang@mediatek.com>
 <1491554709-9723-6-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        matthias.bgg@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        davem@davemloft.net, Landen.Chao@mediatek.com, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1491554709-9723-6-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 07, 2017 at 04:45:09PM +0800, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
> Mediatek router platforms such as MT7623A or MT7623N platform which
> includes 7-port Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY.
> Among these ports, The port from 0 to 4 are the user ports connecting
> with the remote devices while the port 5 and 6 are the CPU ports
> connecting into Mediatek Ethernet GMAC.
> 
> For port 6, it can communicate with the CPU via Mediatek Ethernet GMAC
> through either the TRGMII or RGMII which could be controlled by phy-mode
> in the dt-bindings to specify which mode is preferred to use. And for
> port 5, only RGMII can be specified. However, currently, only port 6 is
> being supported in this DSA driver.
> 
> The driver is made with the reference to qca8k and other existing DSA
> driver. The most of the essential callbacks of the DSA are already
> support in the driver, including tag insert for user port distinguishing,
> port control, bridge offloading, STP setup and ethtool operation to allow
> DSA to model each user port into a standalone netdevice as the other DSA
> driver had done.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> Signed-off-by: Landen Chao <Landen.Chao@mediatek.com>

Hi Sean

This is looking good now. Thanks

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
