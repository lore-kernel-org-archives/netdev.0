From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v7 net-next] net: systemport: Support 64bit statistics
Date: Thu, 3 Aug 2017 16:20:04 -0700
Message-ID: <86aaa85f-ddf3-0904-4d9a-c4edb82e3922@gmail.com>
References: <1501801665-6686-1-git-send-email-jqiaoulk@gmail.com>
 <20170803161604.4d3d5ea1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
        "Jianming.qiao" <jqiaoulk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:38747 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751965AbdHCXUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:20:09 -0400
Received: by mail-wm0-f67.google.com with SMTP id y206so3861171wmd.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:20:08 -0700 (PDT)
In-Reply-To: <20170803161604.4d3d5ea1@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/03/2017 04:16 PM, Stephen Hemminger wrote:
> On Fri,  4 Aug 2017 00:07:45 +0100
> "Jianming.qiao" <jqiaoulk@gmail.com> wrote:
> 
>>  static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
>>  	/* general stats */
>> -	STAT_NETDEV(rx_packets),
>> -	STAT_NETDEV(tx_packets),
>> -	STAT_NETDEV(rx_bytes),
>> -	STAT_NETDEV(tx_bytes),
>> +	STAT_NETDEV64(rx_packets),
>> +	STAT_NETDEV64(tx_packets),
>> +	STAT_NETDEV64(rx_bytes),
>> +	STAT_NETDEV64(tx_bytes),
>>  	STAT_NETDEV(rx_errors),
> 
> Please don't duplicate regular statistics (ie netdev) into ethtool.
> It is a needless duplication.

Agreed, but these are there already and this driver's ethtool::get_stats
is an user ABI of some sort, is not it?
-- 
Florian
