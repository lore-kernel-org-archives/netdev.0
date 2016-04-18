From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ixgbe: use msleep for long delays
Date: Mon, 18 Apr 2016 00:03:58 -0400 (EDT)
Message-ID: <20160418.000358.1382874942962616205.davem@davemloft.net>
References: <1460838941-1251989-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	mark.d.rustad@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460838941-1251989-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sat, 16 Apr 2016 22:35:08 +0200

> The newly added x550em_a support causes a link failure on ARM because of
> an overly long time passed into udelay():
> 
> ERROR: "__bad_udelay" [drivers/net/ethernet/intel/ixgbe/ixgbe.ko] undefined!
> 
> There are multiple variants of the ixgbe_acquire_swfw_sync_*() function,
> and the other ones all use msleep(), so we can safely assume that all
> callers are allowed to sleep, which makes msleep() a better replacement
> than mdelay().
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 49425dfc7451 ("ixgbe: Add support for x550em_a 10G MAC type")

I'm assuming Jeff will pick this up.
