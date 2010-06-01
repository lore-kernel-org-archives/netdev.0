From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next]atl1c: Add AR8151 v2 support and change L0s/L1
 routine
Date: Tue, 01 Jun 2010 00:28:23 -0700 (PDT)
Message-ID: <20100601.002823.124079598.davem@davemloft.net>
References: <12752881361777-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Luis.Rodriguez@Atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <12752881361777-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <jie.yang@atheros.com>
Date: Mon, 31 May 2010 14:42:16 +0800

> From: Jie.Yang@atheros.com
> 
> Add AR8151 v2.0 Gigabit 1000 support
> Change jumbo frame size to 6K
> Update L0s/L1 rountine
>         when link speed is 100M or 1G, set L1 link timer to 4 for l1d_2 and l2c_b2
>         set L1 link timer to 7 for l2c_b, set L1 link timer to 0xF for others.
> Update atl1c_suspend routine
> 	just refactory the function, add atl1c_phy_power_saving routine,
> 	when Wake On Lan enable, this func will be called to save power,
> 	it will reautoneg PHY to 10/100M speed depend on the link
> 	partners link capability.
> Update atl1c_configure_des_ring
>         do not use l2c_b default SRAM configuration.
> 
> Signed-off-by: Jie.Yang@atheros.com

Applied, thank you.
