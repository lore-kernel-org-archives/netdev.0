From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pxa168_eth: move SET_NETDEV_DEV a bit earlier
Date: Wed, 12 Nov 2014 15:08:10 -0500 (EST)
Message-ID: <20141112.150810.806933062338696000.davem@davemloft.net>
References: <1415790527-6494-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antoine.tenart@free-electrons.com, arnd@arndb.de,
	sebastian.hesselbarth@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415790527-6494-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Wed, 12 Nov 2014 19:08:47 +0800

> This is to ensure the net_device's dev.parent is set before we used it
> in dma_zalloc_coherent() from init_hash_table().
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Please always be explicit about what tree you generated this patch against
and therefore expect it to be applied to by saying "[PATCH net-next]" or
similar in your Subject line.

Because this only applies cleanly to net-next, that's where I installed
it.

Thanks.
