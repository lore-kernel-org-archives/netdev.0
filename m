From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH 05/10] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 07:50:34 -0700
Message-ID: <4F86EBBA.6000303@candelatech.com>
References: <1334166738-28243-1-git-send-email-greearb@candelatech.com>  <1334166738-28243-6-git-send-email-greearb@candelatech.com>  (sfid-20120411_195324_260400_4B452B18) <1334202406.3788.8.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1334202406.3788.8.camel-8upI4CBIZJIJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/11/2012 08:46 PM, Johannes Berg wrote:
> On Wed, 2012-04-11 at 10:52 -0700, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:
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

So, move the pertinent header stuff to linux/include/ieee80211.h ??

Thanks,
Ben

>
> johannes


-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
