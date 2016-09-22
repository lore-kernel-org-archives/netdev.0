From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] ftgmac100 support for ast2500
Date: Thu, 22 Sep 2016 03:31:42 -0400 (EDT)
Message-ID: <20160922.033142.971884829340682493.davem@davemloft.net>
References: <20160921230503.23309-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: clg@kaod.org, gwshan@linux.vnet.ibm.com, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: joel@jms.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joel Stanley <joel@jms.id.au>
Date: Thu, 22 Sep 2016 08:34:57 +0930

> Hello Dave,
> 
> This series adds support to the ftgmac100 driver for the Aspeed ast2400 and
> ast2500 SoCs. In particular, they ensure the driver works correctly on the
> ast2500 where the MAC block has seen some changes in register layout.
> 
> They have been tested on ast2400 and ast2500 systems with the NCSI stack and
> with a directly attached PHY.
> 
> V2 reworks the two patches relating to PHYSTS_CHG into the one patch that
> disables the interrupt instead of playing with interrupt sensitivity. I kept
> patch 4 'net/faraday: Clear stale interrupts' which was first introduced to
> clear the stale PHYSTS_CHG interrupt, as it helps keep us safe from unhygienic
> (vendor) bootloaders.

Series applied, thanks.
