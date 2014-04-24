From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 07/13] igb: Cleanups to fix line length warnings
Date: Thu, 24 Apr 2014 12:40:03 -0400 (EDT)
Message-ID: <20140424.124003.1781449604554546212.davem@davemloft.net>
References: <1398335460-4283-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1398335460-4283-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: carolyn.wyborny@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbaDXQkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 12:40:05 -0400
In-Reply-To: <1398335460-4283-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 24 Apr 2014 03:30:54 -0700

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> This patch fixes WARNING:LONG_LINE found with checkpatch check.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_ethtool.c | 13 ++++++++-----
>  drivers/net/ethernet/intel/igb/igb_main.c    |  8 +++++---
>  2 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> index 561df67..6aed00f 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -1129,8 +1129,10 @@ static struct igb_reg_test reg_test_82576[] = {
>  	{ E1000_RDBAH(4),  0x40, 12, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
>  	{ E1000_RDLEN(4),  0x40, 12, PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
>  	/* Enable all RX queues before testing. */
> -	{ E1000_RXDCTL(0), 0x100, 4,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
> -	{ E1000_RXDCTL(4), 0x40, 12,  WRITE_NO_TEST, 0, E1000_RXDCTL_QUEUE_ENABLE },
> +	{ E1000_RXDCTL(0), 0x100, 4, WRITE_NO_TEST, 0,
> +						E1000_RXDCTL_QUEUE_ENABLE },

The second line should start at the same column as E1000_RXDCTL(0) on the first
line, rather than tabbed all the way to outer-space.
