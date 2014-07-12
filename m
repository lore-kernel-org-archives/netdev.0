From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next] enic: Add ethtool support to show classifier
 filters added by the driver
Date: Sat, 12 Jul 2014 14:09:15 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407121406100.1782@ws.cisco>
References: <1405070051-10445-1-git-send-email-_govind@gmx.com> <20140711.145917.653569199285104303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:63233 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbaGLIkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2014 04:40:00 -0400
In-Reply-To: <20140711.145917.653569199285104303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jul 2014, David Miller wrote:

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Fri, 11 Jul 2014 14:44:11 +0530
>
>> Right now Accelerated RFS is the only feature which adds classifier filters.
>> So enable get_rxnfc only when CONFIG_RFS_ACCEL = y
> ...
>> @@ -293,6 +389,9 @@ static const struct ethtool_ops enic_ethtool_ops = {
>>  	.get_ethtool_stats = enic_get_ethtool_stats,
>>  	.get_coalesce = enic_get_coalesce,
>>  	.set_coalesce = enic_set_coalesce,
>> +#ifdef CONFIG_RFS_ACCEL
>> +	.get_rxnfc = enic_get_rxnfc,
>> +#endif
>
> No other driver protects this method in this way, please don't do this.
>

I will move the ifdef's to .h files and resubmit.

Thanks
