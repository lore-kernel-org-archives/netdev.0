From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Sat, 9 Oct 2010 14:27:50 +0100
Message-ID: <20101009132749.GA15074@solarflare.com>
References: <20101009095346.GA12951@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:23037 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908Ab0JIN1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 09:27:53 -0400
Content-Disposition: inline
In-Reply-To: <20101009095346.GA12951@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis Kirjanov wrote:
> Add initial ethtool statistics support 
[...]
> +static void get_ethtool_stats(struct net_device *dev,
> +		struct ethtool_stats *stats, u64 *data)
> +{
> +	struct net_device_stats *netdev_stats = get_stats(dev);
> +	int i = 0;
> +
> +	data[i++] = netdev_stats->tx_packets;
> +	data[i++] = netdev_stats->tx_bytes;
> +	data[i++] = netdev_stats->rx_packets;
> +	data[i++] = netdev_stats->rx_bytes;
> +	data[i++] = netdev_stats->tx_errors;
> +	data[i++] = netdev_stats->tx_dropped;
> +	data[i++] = netdev_stats->rx_errors;
> +}
[...]

There is no point in adding ethtool stats that merely mirror the baseline
net device stats.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
