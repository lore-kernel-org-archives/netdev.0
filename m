From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [Patch net] wl1251: add a missing spin_lock_init()
Date: Fri, 21 Jul 2017 11:00:44 +0300
Message-ID: <87lgni2p8z.fsf@kamboji.qca.qualcomm.com>
References: <1499378437-4971-1-git-send-email-xiyou.wangcong@gmail.com>
        <20170721075407.GA21902@amd>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cong Wang <xiyou.wangcong@gmail.com>, davem@davemloft.net,
        Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37570 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752871AbdGUIAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2017 04:00:49 -0400
In-Reply-To: <20170721075407.GA21902@amd> (Pavel Machek's message of "Fri, 21
        Jul 2017 09:54:07 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Machek <pavel@ucw.cz> writes:

> On Thu 2017-07-06 15:00:37, Cong Wang wrote:
>> This fixes the following kernel warning:
>> 
>>   [ 5668.771453] BUG: spinlock bad magic on CPU#0, kworker/u2:3/9745
>>   [ 5668.771850]  lock: 0xce63ef20, .magic: 00000000, .owner: <none>/-1,
>>   .owner_cpu: 0
> ...
>> by adding the missing spin_lock_init().
>> 
>> Reported-by: Pavel Machek <pavel@ucw.cz>
>> Cc: Kalle Valo <kvalo@codeaurora.org>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>
> Ping? This is pretty trivial bugfix for an ugly problem. It would be
> nice to take it in.

I was on vacation, catching up now but I have 300+ patches in patchwork
so it will take a while before I have gone through all of them.

-- 
Kalle Valo
