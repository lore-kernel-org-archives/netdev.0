From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net/hyperv: Use netif_tx_disable() instead of
 netif_stop_queue() when necessary
Date: Thu, 02 Feb 2012 14:44:21 -0500 (EST)
Message-ID: <20120202.144421.1927599803285674106.davem@davemloft.net>
References: <1328203080-801-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328203080-801-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu,  2 Feb 2012 09:17:59 -0800

> For code path not on the xmit, use netif_tx_disable() instead of
> netif_stop_queue() to ensure other CPUs are not doing xmit.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
