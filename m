From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/4] net: phy: Support "internal" PHY interface
Date: Fri, 23 Jun 2017 10:34:05 -0700
Message-ID: <23546e5b-3ab4-5862-2f31-06380a868c0f@gmail.com>
References: <20170623173316.23017-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS"
        <devicetree@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>,
        david.wu@rock-chips.com, opendmb@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170623173316.23017-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/23/2017 10:33 AM, Florian Fainelli wrote:
> Hi all,
> 
> This makes the "internal" phy-mode property generally available and
> documented and this allows us to remove some custom parsing code
> we had for bcmgenet and bcm_sf2 which both used that specific value.

Sorry for the resend, this is net-next material.

> 
> Florian Fainelli (4):
>   dt-bindings: Add "internal" as a valid 'phy-mode' property
>   net: phy: Support "internal" PHY interface
>   net: bcmgenet: Remove special handling of "internal" phy-mode
>   net: dsa: bcm_sf2: Remove special handling of "internal" phy-mode
> 
>  Documentation/devicetree/bindings/net/ethernet.txt |  1 +
>  drivers/net/dsa/bcm_sf2.c                          | 16 +++++----------
>  drivers/net/ethernet/broadcom/genet/bcmmii.c       | 24 ++++++++--------------
>  include/linux/phy.h                                |  3 +++
>  4 files changed, 17 insertions(+), 27 deletions(-)
> 


-- 
Florian
