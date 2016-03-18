From: Luis de Bethencourt <luisbg-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Subject: Re: [PATCH] mac80211: fix order of flag descriptions
Date: Fri, 18 Mar 2016 18:20:05 +0000
Message-ID: <56EC46D5.6030809@osg.samsung.com>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com> <1458318955-32070-1-git-send-email-luisbg@osg.samsung.com> <1458319756.13729.1.camel@sipsolutions.net> <56EC3EF1.50805@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56EC3EF1.50805-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 18/03/16 17:46, Luis de Bethencourt wrote:
> On 18/03/16 16:49, Johannes Berg wrote:
>> On Fri, 2016-03-18 at 16:35 +0000, Luis de Bethencourt wrote:
>>> Fix order of mac80211_rx_flags description to match the enum.
>>>
>>> Signed-off-by: Luis de Bethencourt <luisbg-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
>>> ---
>>> Hi,
>>>
>>> I want ahead and fixed the order of the descriptions. checkpatch.pl
>>> was giving
>>> a warning to my previous patch and I had a hunch it was because the
>>> wrong order
>>> breaks the parser. Indeed it does and with this patch below
>>> checkpatch.pl does
>>> not complain about this flag descriptions anymore.
>>>
>> Huh. I think we should fix checkpatch.pl instead. While the current
>> order isn't likely really good, I believe kernel-doc will output the
>> documentation in the order it's listed, and that can be useful for the
>> documentation output to group related things, even if their bits may be
>> further apart.
>>
>> johannes
>>
> 
> I agree checkpatch.pl should be fixed. I can look into it. No promises
> though, it has been a long time since I look at Perl code.
> 
> I understand the logic of grouping the documentation in logical blocks.
> It is unfortunate though that this means the enum and documentation won't
> match, which makes reading the code harder.
> 
> In this particular case I don't see the order of the documentation broken
> because flags are being grouped.
> 
> Thanks for the review :)
> Luis
> 

Sorry Johannes,

Update. checkpatch doesn't need fixing and it does see the documentation
independently of the order. It was my mistake.

Joe Perches pointed it out in this email branch:
https://lkml.org/lkml/2016/3/18/532


Thanks for looking into this, sorry for my blunder.
Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
