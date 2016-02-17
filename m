From: Ross Green <rgkernel@gmail.com>
Subject: Re: wlcore: Fix regression in wlcore_set_partition()
Date: Wed, 17 Feb 2016 16:34:46 +1100
Message-ID: <CANfgCY0zHtE8Z8knNPsTgnZS-fumdeioU45F1E2KtvpLBckQDg@mail.gmail.com>
References: <20160210012216.GA18819@lianli>
	<20160212094526.EC572611CE@smtp.codeaurora.org>
	<CANfgCY02_AkRi2EMNZsneK8UdwLvAWxF_X0ts6WZbaM0=5c63A@mail.gmail.com>
	<87bn7gu19c.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Emil Goode <emil.fsw@goode.io>, Shahar Patury <shaharp@ti.com>,
	Guy Mishol <guym@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35866 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460AbcBQFes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 00:34:48 -0500
In-Reply-To: <87bn7gu19c.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Appreciate your efforts!

Just trying to make sure it does not get lost.
Introduced in rc1, not fixed by ... rc4.

Anyway, I will continue to test, lots of other things still to chase
even in rc4!

Regards,

Ross Green

On Wed, Feb 17, 2016 at 2:24 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Ross Green <rgkernel@gmail.com> writes:
>
>> On Fri, Feb 12, 2016 at 8:45 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>>
>>>> The commit 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio") introduced a
>>>> regression causing the wlcore to time out and go into recovery. Reverting the
>>>> changes regarding write of the last partition size brings the module back to
>>>> it's functional state.
>>>>
>>>> Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
>>>> Reported-by: Ross Green <rgkernel@gmail.com>
>>>> Signed-off-by: Emil Goode <emil.fsw@goode.io>
>>>> [kvalo@codeaurora.org: improved commit log]
>>>
>>> Thanks, applied to wireless-drivers.git.
>>>
>>> Kalle Valo
>>
>> I just tested linux-4.5-rc4 it appears the above fix missed the release for rc4!
>> So the behaviour of firmware reset being called after the access of
>> the last partition timesout.
>>
>> Again tested patch with the new release - 4.5-rc4 and found everything
>> to work as expected again.
>>
>> So Hopefully for rc5 - Please!
>
> It takes some time to get patches into Linus' tree. And being in a
> conference and then getting sick is not really helping. I'm not sure if
> this patch makes to rc5 on time, but I'll try.
>
> --
> Kalle Valo
