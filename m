From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 05/10] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 08:23:26 -0700
Message-ID: <4F86F36E.5010708@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>  <1334166738-28243-6-git-send-email-greearb@candelatech.com>  (sfid-20120411_195324_260400_4B452B18) <1334202406.3788.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43190 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933900Ab2DLPX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 11:23:29 -0400
In-Reply-To: <1334202406.3788.8.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2012 08:46 PM, Johannes Berg wrote:
> On Wed, 2012-04-11 at 10:52 -0700, greearb@candelatech.com wrote:
>
>> --- a/net/mac80211/cfg.c
>> +++ b/net/mac80211/cfg.c
>> @@ -19,6 +19,7 @@
>>   #include "cfg.h"
>>   #include "rate.h"
>>   #include "mesh.h"
>> +#include "../wireless/core.h"
>
> NACK. Don't do that.

Looks like whatever I needed has already been moved somewhere
proper...I can just delete that line and it compiles fine.

Thanks,
Ben

>
> johannes


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
