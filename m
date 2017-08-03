From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 net-next] net: systemport: Support 64bit statistics
Date: Thu, 03 Aug 2017 16:45:54 -0700 (PDT)
Message-ID: <20170803.164554.1116282475558581464.davem@davemloft.net>
References: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
        <20170803161604.4d3d5ea1@xeon-e3>
        <86aaa85f-ddf3-0904-4d9a-c4edb82e3922@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, jqiaoulk@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51372 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbdHCXp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:45:57 -0400
In-Reply-To: <86aaa85f-ddf3-0904-4d9a-c4edb82e3922@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 3 Aug 2017 16:20:04 -0700

> On 08/03/2017 04:16 PM, Stephen Hemminger wrote:
>> On Fri,  4 Aug 2017 00:07:45 +0100
>> "Jianming.qiao" <jqiaoulk@gmail.com> wrote:
>> 
>>>  static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
>>>  	/* general stats */
>>> -	STAT_NETDEV(rx_packets),
>>> -	STAT_NETDEV(tx_packets),
>>> -	STAT_NETDEV(rx_bytes),
>>> -	STAT_NETDEV(tx_bytes),
>>> +	STAT_NETDEV64(rx_packets),
>>> +	STAT_NETDEV64(tx_packets),
>>> +	STAT_NETDEV64(rx_bytes),
>>> +	STAT_NETDEV64(tx_bytes),
>>>  	STAT_NETDEV(rx_errors),
>> 
>> Please don't duplicate regular statistics (ie netdev) into ethtool.
>> It is a needless duplication.
> 
> Agreed, but these are there already and this driver's ethtool::get_stats
> is an user ABI of some sort, is not it?

Agreed, they have to stay at this point.
