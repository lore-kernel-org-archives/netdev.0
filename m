From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [NET-NEXT v4 PATCH 1/5] ixgbe: this patch adds support for DCB
 to the	kernel and ixgbe driver
Date: Fri, 21 Nov 2008 17:14:16 +0800
Message-ID: <49267BE8.6020205@cn.fujitsu.com>
References: <20081121020055.22180.24154.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56184 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751769AbYKUJOc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 04:14:32 -0500
In-Reply-To: <20081121020055.22180.24154.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher said the following on 2008-11-21 10:00:
> diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
> index a610016..aaa4404 100644
> --- a/drivers/net/ixgbe/ixgbe_ethtool.c
> +++ b/drivers/net/ixgbe/ixgbe_ethtool.c
> @@ -97,9 +97,18 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
>  	((((struct ixgbe_adapter *)netdev_priv(netdev))->num_tx_queues + \
>  	((struct ixgbe_adapter *)netdev_priv(netdev))->num_rx_queues) * \
>  	(sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
> -#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
>  #define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
> -#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
> +#define IXGBE_PB_STATS_LEN ( \
> +                 (((struct ixgbe_adapter *)netdev->priv)->flags & \

Dave, please don't hate me. :)
I know you've applied it.
But I don't want this directly reference of netdev->priv.

