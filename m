From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: [PATCH v2 4/4] ath9k:  Support ethtool getstats api.
Date: Fri, 16 Mar 2012 14:26:34 -0700
Message-ID: <4F63B00A.4050904@candelatech.com>
References: <1331927952-8706-1-git-send-email-greearb@candelatech.com>  <1331927952-8706-4-git-send-email-greearb@candelatech.com>  <1331931232.2504.9.camel@bwh-desktop.uk.solarflarecom.com> <1331931427.2504.12.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1331931427.2504.12.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/16/2012 01:57 PM, Ben Hutchings wrote:
> On Fri, 2012-03-16 at 20:53 +0000, Ben Hutchings wrote:
>> On Fri, 2012-03-16 at 12:59 -0700, greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org wrote:
>>> From: Ben Greear<greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
>>>
>>> This returns many of the values that formerly could
>>> only be obtained from debugfs.  This should be an
>>> improvement when trying to access these counters
>>> programatically.  Currently this support is only
>>> enabled when DEBUGFS is enabled because otherwise
>>> these stats are not accumulated.
>> [...]
>>
>> Given that ethtool (unlike debugfs) is itself an unconditional feature,
>> why not make this unconditional?  Is it expensive to accumulate the
>> stats?
>>
>> Please at least fix the name.
>                           ^ config option
>

The ath9k stats are currently only gathered when debugfs is enabled.

I could do some patches in the future to allow stats to always
be gathered regardless of debugfs being enabled, but since
ath9k is used on small form factor systems, there may be some
resistance to enabling that all the time.

Thanks,
Ben

-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
