From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Sat, 09 Oct 2010 18:40:59 +0400
Message-ID: <4CB07EFB.4020307@kernel.org>
References: <20101009095346.GA12951@hera.kernel.org> <20101009132749.GA15074@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42354 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755480Ab0JIOk6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Oct 2010 10:40:58 -0400
In-Reply-To: <20101009132749.GA15074@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2010 05:27 PM, Ben Hutchings wrote:
> Denis Kirjanov wrote:
>> Add initial ethtool statistics support 
> [...]
>> +static void get_ethtool_stats(struct net_device *dev,
>> +		struct ethtool_stats *stats, u64 *data)
>> +{
>> +	struct net_device_stats *netdev_stats = get_stats(dev);
>> +	int i = 0;
>> +
>> +	data[i++] = netdev_stats->tx_packets;
>> +	data[i++] = netdev_stats->tx_bytes;
>> +	data[i++] = netdev_stats->rx_packets;
>> +	data[i++] = netdev_stats->rx_bytes;
>> +	data[i++] = netdev_stats->tx_errors;
>> +	data[i++] = netdev_stats->tx_dropped;
>> +	data[i++] = netdev_stats->rx_errors;
>> +}
> [...]
> 
> There is no point in adding ethtool stats that merely mirror the baseline
> net device stats.
Fair enough,
I'll add extra stats shortly
> Ben.
> 

