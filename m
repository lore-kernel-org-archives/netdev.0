From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: add extension of phy-mode for XLGMII
Date: Wed, 04 Jan 2017 13:42:07 -0500 (EST)
Message-ID: <20170104.134207.1106369954702793597.davem@davemloft.net>
References: <b5378ab79043fe46027756546c17e0a54df4a9f0.1483505550.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jie.Deng1@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b5378ab79043fe46027756546c17e0a54df4a9f0.1483505550.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jie Deng <Jie.Deng1@synopsys.com>
Date: Wed, 4 Jan 2017 13:04:04 +0800

> The Synopsys DWC_xlgmac core provides a multiplexed 40-Gigabit
> Media-Independent Interface (XLGMII, an IEEE 802.3 Clause 81
> compliant reconciliation sub-layer) for communication with
> the 100/50/40/25-Gigabit PHY and 10-Gigabit Media-Independent
> Interface (XGMII, an IEEE 802.3 Clause 46 compliant reconciliation
> sub-layer) for communication with the 10-Gigabit PHY.
> 
> Currently, There are only interface mode definitions for "xgmii".
> This patch adds the definitions for the PHY layer to recognize
> "xlgmii" as a valid PHY interface.
> 
> Signed-off-by: Jie Deng <jiedeng@synopsys.com>

It makes no sense to add these definitions unless you also submit
uses of them alongside at the same time.

Thanks.
