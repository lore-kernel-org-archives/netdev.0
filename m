From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: adjust cpsw fifos depth for
 fullduplex flow control
Date: Mon, 08 May 2017 17:33:33 -0400 (EDT)
Message-ID: <20170508.173333.1140782402828347971.davem@davemloft.net>
References: <20170508192121.20451-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com, ivan.khoronzhuk@linaro.org,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        spatton@ti.com
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170508192121.20451-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Mon, 8 May 2017 14:21:21 -0500

> When users set flow control using ethtool the bits are set properly in the
> CPGMAC_SL MACCONTROL register, but the FIFO depth in the respective Port n
> Maximum FIFO Blocks (Pn_MAX_BLKS) registers remains set to the minimum size
> reset value. When receive flow control is enabled on a port, the port's
> associated FIFO block allocation must be adjusted. The port RX allocation
> must increase to accommodate the flow control runout. The TRM recommends
> numbers of 5 or 6.
> 
> Hence, apply required Port FIFO configuration to
> Pn_MAX_BLKS.Pn_TX_MAX_BLKS=0xF and Pn_MAX_BLKS.Pn_RX_MAX_BLKS=0x5 during
> interface initialization.
> 
> Cc: Schuyler Patton <spatton@ti.com>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied.
