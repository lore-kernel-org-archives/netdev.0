From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8851: Fix NOHZ local_softirq_pending 08 warning
Date: Mon, 13 Feb 2012 16:02:25 -0500 (EST)
Message-ID: <20120213.160225.1376918979432253989.davem@davemloft.net>
References: <1329154632-12745-1-git-send-email-b-cousson@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: b-cousson@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1329154632-12745-1-git-send-email-b-cousson@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benoit Cousson <b-cousson@ti.com>
Date: Mon, 13 Feb 2012 18:37:12 +0100

> This fix a similar problem as in 72092cc45378176ba700034c91b7af2db524df26
> and 481a8199142c050b72bff8a1956a49fd0a75bbe0 ("can:
> fix NOHZ local_softirq_pending 08 warning"). This fix replaces netif_rx()
> with netif_rx_ni() which has to be used from process/softirq context.
> 
> Signed-off-by: Benoit Cousson <b-cousson@ti.com>

Applied.
