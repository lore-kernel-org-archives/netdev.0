From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [V2,for,3.19,3/7] rtlwifi: rtl8192ee: Fix adhoc fail
Date: Tue, 03 Feb 2015 10:00:45 -0600
Message-ID: <54D0F0AD.7070209@lwfinger.net>
References: <20150203131516.799471409D0@smtp.codeaurora.org> <87r3u7w2l5.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Troy Tan <troy_tan@realsil.com.cn>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:39241 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966013AbbBCQAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 11:00:49 -0500
In-Reply-To: <87r3u7w2l5.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2015 07:23 AM, Kalle Valo wrote:
> Kalle Valo <kvalo@codeaurora.org> writes:
>
>>> From: Troy Tan <troy_tan@realsil.com.cn>
>>>
>>> When the buffer descriptor index exceeds 2, then a TX HANG condition
>>> will result.
>>>
>>> Signed-off-by: Troy Tan <troy_tan@realsil.com.cn>
>>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>>> Cc: Stable <stable@vger.kernel.org> [V3.18]
>>
>> Thanks, 4 patches applied to wireless-drivers-next.git:
>>
>> b661a5da5776 rtlwifi: rtl8192ee: Fix adhoc fail
>> 6e5f44361628 rtlwifi: rtl8192ee: Fix TX hang due to failure to update TX write point
>> 92ff754240b8 rtlwifi: rtl8192ee: Fix parsing of received packet
>> 21b39ddb5bb2 rtlwifi: rtl8192ee: Fix DMA stalls
>>
>> 3 patches skipped:
>
> I had to skip these three patches because of my mistake. So what I did
> was that I had merged ("fast forwarded") the net tree into my
> wireless-drivers tree and not realising I should not do that. So now I
> can't merge wireless-drivers into wireless-drivers-next anymore, as it
> will pull unnecessary net changes.
>
>> [V2,for,3.19,1/7] rtlwifi: Remove logging statement that is no longer
>> needed
>
> I'll apply this after 3.20-rc1 is released, it should apply then without
> problems (or the conflicts are easy for me to fix). Luckily this is just
> a cosmetic error and can wait for 3.20-rc2, right?

That is correct. 3.20-rc2 will be OK. I'll probably get a bunch of "your **** 
driver is spamming my logs, but I can ignore them".

>
>> [V2,for,3.19,2/7] rtlwifi: rtl8192ee: Fix handling of new style descriptors
>> [V2,for,3.19,6/7] rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO
>
> Not sure what to do with these one. Should you rebase and send them now?

These two fix real bugs and need to be in the kernel ASAP. Unfortunately, I saw 
you pass them off to DaveM and I deleted them from my "Submitted Patch" list. I 
can recreate them from my working copy of wireless-drivers, and I will resubmit. 
When I do, please process them as quickly as possible.

Thanks,

Larry
