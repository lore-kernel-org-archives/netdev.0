From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Wed, 13 Apr 2016 11:15:13 -0400 (EDT)
Message-ID: <20160413.111513.295841881765244758.davem@davemloft.net>
References: <20160413175028.5d3a4cf2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mark.d.rustad@intel.com,
	jeffrey.t.kirsher@intel.com, andrewx.bowers@intel.com,
	broonie@kernel.org, kernel-build-reports@lists.linaro.org,
	linaro-kernel@lists.linaro.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160413175028.5d3a4cf2@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 13 Apr 2016 17:50:28 +1000

> After merging the net-next tree, today's linux-next build (arm
> allmodconfig) failed like thisi (this has actually been failing for a
> few days, now):
> 
> ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko] undefined!
> 
> Caused by commit
> 
>   49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC type")
> 
> arm only allows udelay()s up to 2 milliseconds.  This commit
> adds a 5 ms udelay in ixgbe_acquire_swfw_sync_x550em_a() in
> drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c.

Jeff, please have your folks look into this.  Probably just a simple
conversion to mdelay().

Thanks!
