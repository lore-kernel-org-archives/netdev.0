From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: fix kernel OOPS when remove
 davinci_mdio module
Date: Fri, 31 Aug 2012 16:35:36 -0400 (EDT)
Message-ID: <20120831.163536.537028996029525033.davem@davemloft.net>
References: <1346344652-28487-1-git-send-email-b-liu@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, vaibhav.bedia@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: b-liu@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346344652-28487-1-git-send-email-b-liu@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bin Liu <b-liu@ti.com>
Date: Thu, 30 Aug 2012 11:37:32 -0500

> davinci mdio device is not unregistered from mdiobus when removing
> the module, which causes BUG_ON() when free the device from mdiobus.
> 
> Calling mdiobus_unregister() before mdiobus_free() fixes the issue.
> 
> Signed-off-by: Bin Liu <b-liu@ti.com>

Applied, thanks.
