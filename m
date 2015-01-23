From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH V2 for 3.19 0/7] Fixes for rtl8192ee
Date: Fri, 23 Jan 2015 10:40:21 -0600
Message-ID: <54C27975.50501@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net> <873871msc7.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	=?UTF-8?B?InRyb3lfdGFuQHJlYWxzaWwuY29tLmNuID4+IOiwreadreazoiI=?=
	<troy_tan@realsil.com.cn>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:50528 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755611AbbAWQk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 11:40:29 -0500
In-Reply-To: <873871msc7.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2015 09:26 AM, Kalle Valo wrote:
> Larry Finger <Larry.Finger@lwfinger.net> writes:
>
>> This is V2 of the patches for rtl8192ee to be applied to 3.19. They replace
>> all the patches submitted under the title '[PATCH for 3.19 0/3] rtlwifi:
>> Various updates/fixes". All are marked for backporting to 3.18.
>>
>> The first of these removes a logging statement that is no longer needed.
>>
>> Patches 1-6 are relatively small and should not be a problem for 3.19.
>> Patch 7 is quite a bit larger, and adds two new routines to detect
>> DMA stalls. I will understand if you want to defer that to -next; however,
>> it does fix a serious problem.
>
> -rc6 is most likely released on Sunday, I cannot send six patches this
> late in the cycle unless our inboxes are filling of bug reports. As my
> inbox seems to be pretty empty about rtlwifi problems can you give more
> background why you think it's important to get these to 3.19? Are these
> all regressions from 3.18 or older bugs which just got fixed now?
>
>>    rtlwifi: Remove logging statement that is no longer needed
>
> I think this is ok.
>
>>    rtlwifi: rtl8192ee: Fix adhoc fail
>
> Ad-Hoc mode is not that popular, IMHO this can easily wait for -next.
>
>>    rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO
>>    rtlwifi: rtl8192ee: Fix handling of new style descriptors
>>    rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write
>>      point
>>    rtlwifi: rtl8192ee: Fix parsing of received packet
>>    rtlwifi: rtl8192ee: Fix DMA stalls
>
> For -rc1 or -rc2 these would have been ok, but without really good
> justifications getting these into -rc7 is difficult.
>
> But the patches itself are create, huge improvement compared to v1.

Kalle,

It is too bad that it took so long to get these ready. I think the reason that 
there are not a lot of bug reports is because the complaints are all in the 
GitHub issues for the rtlwifi_new repo, or with Ubuntu. If there are any that 
get filed against Bugzilla, I will refer them to that repo.

Driver rtl8192ee was new in 3.18. There had been a previous version in staging, 
but it did not get a lot of usage. I'm not sure if the additional usage after 
3.18 was due to the driver being in the regular tree, or if vendors started 
using the chips, but the problem reports started arriving. All these bugs have 
been part of rtl8192ee since it has been in the kernel, thus they are hard to 
categorize as regressions.

Push all 7 into -next so that they will be in 3.20. If you think it to be 
prudent, please leave the Cc for stable. That way 3.18 and 3.19 will eventually 
get the fixes.

Thanks,

Larry
