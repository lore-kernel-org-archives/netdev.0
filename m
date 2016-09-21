From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH net-next 0/7] ftgmac100 support for ast2500
Date: Thu, 22 Sep 2016 08:34:55 +0930
Message-ID: <CACPK8XfCScgeq5bGEQTpggtSFMzipzOwNwOTW2UZkRSq7sMPeA@mail.gmail.com>
References: <20160921230334.23224-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?C=C3=A9dric_Le_Goater?= <clg@kaod.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>,
        Andrew Lunn <andrew@lunn.ch>, Andrew Jeffery <andrew@aj.id.au>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921230334.23224-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please ignore this one.

On Thu, Sep 22, 2016 at 8:33 AM, Joel Stanley <joel@jms.id.au> wrote:
> Hello Dave,
>
> This series adds support to the ftgmac100 driver for the Aspeed ast2400 and
> ast2500 SoCs. In particular, they ensure the driver works correctly on the
> ast2500 where the MAC block has seen some changes in register layout.
>
> They have been tested on ast2400 and ast2500 systems with the NCSI stack and
> with a directly attached PHY.
>
> Cheers,
>
> Joel
>
> Andrew Jeffery (2):
>   net/ftgmac100: Separate rx page storage from rxdesc
>   net/ftgmac100: Make EDO{R,T}R bits configurable
>
> Gavin Shan (2):
>   net/faraday: Avoid PHYSTS_CHG interrupt
>   net/faraday: Clear stale interrupts
>
> Joel Stanley (3):
>   net/ftgmac100: Adapt for Aspeed SoCs
>   net/faraday: Fix phy link irq on Aspeed G5 SoCs
>   net/faraday: Configure old MDIO interface on Aspeed SoCs
>
>  drivers/net/ethernet/faraday/ftgmac100.c | 92 ++++++++++++++++++++++++--------
>  drivers/net/ethernet/faraday/ftgmac100.h |  8 ++-
>  2 files changed, 77 insertions(+), 23 deletions(-)
>
> --
> 2.9.3
>
