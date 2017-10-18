From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: ftgmac100: Request clock and set speed
Date: Wed, 18 Oct 2017 12:09:29 +0100 (WEST)
Message-ID: <20171018.120929.1774171348326334992.davem@davemloft.net>
References: <20171013041638.30763-1-joel@jms.id.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, andrew@aj.id.au
To: joel@jms.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013041638.30763-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joel Stanley <joel@jms.id.au>
Date: Fri, 13 Oct 2017 12:16:38 +0800

> According to the ASPEED datasheet, gigabit speeds require a clock of
> 100MHz or higher. Other speeds require 25MHz or higher. This patch
> configures a 100MHz clock if the system has a direct-attached
> PHY, or 25MHz if the system is running NC-SI which is limited to 100MHz.
> 
> There appear to be no other upstream users of the FTGMAC100 driver it is
> hard to know the clocking requirements of other platforms. Therefore a
> conservative approach was taken with enabling clocks. If the platform is
> not ASPEED, both requesting the clock and configuring the speed is
> skipped.
> 
> Signed-off-by: Joel Stanley <joel@jms.id.au>

Applied to net-next, thanks.
