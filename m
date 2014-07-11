From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] enic: Add ethtool support to show classifier
 filters added by the driver
Date: Fri, 11 Jul 2014 14:59:17 -0700 (PDT)
Message-ID: <20140711.145917.653569199285104303.davem@davemloft.net>
References: <1405070051-10445-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57907 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbaGKV7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 17:59:18 -0400
In-Reply-To: <1405070051-10445-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Fri, 11 Jul 2014 14:44:11 +0530

> Right now Accelerated RFS is the only feature which adds classifier filters.
> So enable get_rxnfc only when CONFIG_RFS_ACCEL = y
 ...
> @@ -293,6 +389,9 @@ static const struct ethtool_ops enic_ethtool_ops = {
>  	.get_ethtool_stats = enic_get_ethtool_stats,
>  	.get_coalesce = enic_get_coalesce,
>  	.set_coalesce = enic_set_coalesce,
> +#ifdef CONFIG_RFS_ACCEL
> +	.get_rxnfc = enic_get_rxnfc,
> +#endif

No other driver protects this method in this way, please don't do this.
