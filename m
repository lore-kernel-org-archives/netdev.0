From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Sat, 09 Oct 2010 17:48:38 -0400
Message-ID: <4CB0E336.9010605@garzik.org>
References: <20101009095346.GA12951@hera.kernel.org> <20101009132749.GA15074@solarflare.com> <4CB0C56C.2000106@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55770 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757267Ab0JIVsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 17:48:46 -0400
Received: by vws2 with SMTP id 2so247268vws.19
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 14:48:45 -0700 (PDT)
In-Reply-To: <4CB0C56C.2000106@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2010 03:41 PM, Denis Kirjanov wrote:
> On 10/09/2010 05:27 PM, Ben Hutchings wrote:
>> Denis Kirjanov wrote:
>>> Add initial ethtool statistics support
>> [...]
>>> +static void get_ethtool_stats(struct net_device *dev,
>>> +		struct ethtool_stats *stats, u64 *data)
>>> +{
>>> +	struct net_device_stats *netdev_stats = get_stats(dev);
>>> +	int i = 0;
>>> +
>>> +	data[i++] = netdev_stats->tx_packets;
>>> +	data[i++] = netdev_stats->tx_bytes;
>>> +	data[i++] = netdev_stats->rx_packets;
>>> +	data[i++] = netdev_stats->rx_bytes;
>>> +	data[i++] = netdev_stats->tx_errors;
>>> +	data[i++] = netdev_stats->tx_dropped;
>>> +	data[i++] = netdev_stats->rx_errors;
>>> +}
>> [...]
>>
>> There is no point in adding ethtool stats that merely mirror the baseline
>> net device stats.
>>
>> Ben.
>>
>
> [PATCH -next v2] sundance: Add ethtool stats support
>
> Add ethtool stats support
>
> Signed-off-by: Denis Kirjanov<dkirjanov@kernel.org>
> ---
> V2:
>   check for the ETH_SS_STATS in get_string()
>   use xstats struct for ethtool stats
>
> drivers/net/sundance.c |   90 ++++++++++++++++++++++++++++++++++++++++++++----
>   1 files changed, 83 insertions(+), 7 deletions(-)

Acked-by: Jeff Garzik <jgarzik@redhat.com>

glad somebody tackled this...


