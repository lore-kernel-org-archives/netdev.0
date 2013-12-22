From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Sun, 22 Dec 2013 11:33:19 -0800
Message-ID: <CAM_iQpXXD0rHiYxGvXiN7G8BtVdTQV6Xixma6BENoZ5SZ2XjZg@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
	<52B60384.6000002@mojatatu.com>
	<52B712D3.9050605@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33906 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143Ab3LVTdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 14:33:19 -0500
Received: by mail-ob0-f173.google.com with SMTP id gq1so4758679obb.32
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 11:33:19 -0800 (PST)
In-Reply-To: <52B712D3.9050605@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 22, 2013 at 8:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 12/21/13 16:09, Jamal Hadi Salim wrote:
>>
>> On 12/20/13 18:49, Cong Wang wrote:
>>
>>> Jamal, any comments on this patch itself?
>>>
>>
>> I think the idea is good. Sorry havent paid close
>> attention - starting to look at what is already
>> in net-next. I could pass you a test or two to run
>> for this change...
>>
>
>
> BTW: This indev feature was supposed to be "temporary";->
> but has stuck around all these years. Not sure how widely it is

I knew, ematch does much better. :)
But once you added an API, it is hard to remove it...

> used. I will send you a testcase shortly. If it passes for you
> please add my ACKed-by
>

Will do.

Thanks.
