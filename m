From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv643xx_eth: fix build failure
Date: Sat, 17 Dec 2016 21:47:39 -0500 (EST)
Message-ID: <20161217.214739.440356560135251249.davem@davemloft.net>
References: <1481935505-24475-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: sudipm.mukherjee@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481935505-24475-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Date: Sat, 17 Dec 2016 00:45:05 +0000

> The build of sparc allmodconfig fails with the error:
> "of_irq_to_resource" [drivers/net/ethernet/marvell/mv643xx_eth.ko]
> 	undefined!
> 
> of_irq_to_resource() is defined when CONFIG_OF_IRQ is defined. And also
> CONFIG_OF_IRQ can only be defined if CONFIG_IRQ is defined. So we can
> safely use #if defined(CONFIG_OF_IRQ) in the code.
> 
> Signed-off-by: Sudip Mukherjee <sudip.mukherjee@codethink.co.uk>

Applied, thanks.
