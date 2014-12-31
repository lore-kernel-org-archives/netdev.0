From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: Re: [PATCH net-next v1 4/5] ixgbevf: Add RSS Key query code
Date: Wed, 31 Dec 2014 20:03:19 +0200
Message-ID: <54A43A67.9020407@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>	 <1420019519-18139-5-git-send-email-vladz@cloudius-systems.com> <1420043307.31582.53.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:49115 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaLaSDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 13:03:22 -0500
Received: by mail-wg0-f42.google.com with SMTP id k14so22528175wgh.29
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 10:03:21 -0800 (PST)
In-Reply-To: <1420043307.31582.53.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/31/14 18:28, Jeff Kirsher wrote:
> On Wed, 2014-12-31 at 11:51 +0200, Vlad Zolotarov wrote:
>> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
>> ---
>> New in v1 (compared to RFC):
>>     - Use "if-else" statement instead of a "switch-case" for a single
>> option case
>>       (in ixgbevf_get_rss_key()).
>>
>> ---
>>   drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
>>   drivers/net/ethernet/intel/ixgbevf/vf.c  | 44
>> ++++++++++++++++++++++++++++++++
>>   drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
>>   3 files changed, 47 insertions(+)
> Just caught this now, sorry but your patch description is sparse (i.e.
> non-existent).  I know that the title of the patch pretty much tells
> what you are doing, but it would be nice to have a bit more detail as to
> why (like your first patch).

I've sent a v2 where I tried to address your last remarks. Pls., note 
that the whole series "why" motivation is located in the PATCH0 and in 
the final PATCH5: adding a new ethtool options for 82599 VF devices.

thanks,
vlad

>
> Same goes for patch 5 of the series as well.
