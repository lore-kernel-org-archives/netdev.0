From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2,1/1] hv_netvsc: use per_cpu stats to
 calculate TX/RX data
Date: Thu, 14 May 2015 22:49:58 -0400 (EDT)
Message-ID: <20150514.224958.144644873953606975.davem@davemloft.net>
References: <1431590425-23889-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431590425-23889-1-git-send-email-sixiao@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Xiao <sixiao@microsoft.com>
Date: Thu, 14 May 2015 01:00:25 -0700

> Current code does not lock anything when calculating the TX and RX stats.
> As a result, the RX and TX data reported by ifconfig are not accuracy in a
> system with high network throughput and multiple CPUs (in my test,
> RX/TX = 83% between 2 HyperV VM nodes which have 8 vCPUs and 40G Ethernet).
> 
> This patch fixed the above issue by using per_cpu stats.
> netvsc_get_stats64() summarizes TX and RX data by iterating over all CPUs
> to get their respective stats.
> 
> This v2 patch addressed David's comments on the cleanup path when
> netdev_alloc_pcpu_stats() failed.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied, thanks.
