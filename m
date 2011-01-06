From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH 2/3] tlan: Fix partner capability printout
Date: Thu, 06 Jan 2011 21:36:28 +0200
Message-ID: <4D2619BC.1030606@iki.fi>
References: <4D260ED0.5040301@iki.fi>	 <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>	 <1294339817-31434-2-git-send-email-sakari.ailus@iki.fi> <1294341774.11825.27.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:36930 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753064Ab1AFTga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:36:30 -0500
In-Reply-To: <1294341774.11825.27.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Thu, 2011-01-06 at 20:50 +0200, Sakari Ailus wrote:
>> Fix partner capability printout. Add spaces and do not print null.
>>
>> Signed-off-by: Sakari Ailus<sakari.ailus@iki.fi>
>> ---
>>   drivers/net/tlan.c |    6 +++---
>>   1 files changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
>> index 57380b1..090ce21 100644
>> --- a/drivers/net/tlan.c
>> +++ b/drivers/net/tlan.c
>> @@ -2367,10 +2367,10 @@ tlan_finish_reset(struct net_device *dev)
>>   					? "" : "0",
>>   					tlphy_par&  TLAN_PHY_DUPLEX_FULL
>>   					? "Full" : "half");
>> -				pr_info("TLAN: Partner capability: ");
>> -				for (i = 5; i<= 10; i++)
>> +				pr_info("TLAN: Partner capability:");
>> +				for (i = 5; i<  10; i++)
>>   					if (partner&  (1<<i))
>> -						printk("%s", media[i-5]);
>> +						printk(" %s", media[i-5]);
>>   				printk("\n");
>>   			}
>>
>
> Really you should remove this logging and report the information through
> the ethtool interface.

Hi Ben,

Thanks for the comments.

The driver supports mii-tool but not ethtool. Do you think it'd be fine 
to remove these prints with just mii-tool interface support?

I agree ethtool support would definitely make sense to have in tlan.

Regards,

-- 
Sakari Ailus
sakari.ailus@iki.fi
