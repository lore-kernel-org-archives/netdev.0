From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next] net_sched: properly handle failure case of
 tcf_exts_init()
Date: Mon, 22 Aug 2016 14:12:04 -0400
Message-ID: <802eede6-be83-133b-5413-d9d26a317419@mojatatu.com>
References: <1471635414-32433-1-git-send-email-xiyou.wangcong@gmail.com>
 <09b957e2-5a37-643d-9cc1-2bbddc4ad8b4@mojatatu.com>
 <CAM_iQpVJt9fE_anNXq=Jvi_Ka=BtN-_H365+oEBpFrxJv6dU3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35579 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752945AbcHVSMS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 14:12:18 -0400
Received: by mail-it0-f68.google.com with SMTP id f6so5389726ith.2
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:12:18 -0700 (PDT)
In-Reply-To: <CAM_iQpVJt9fE_anNXq=Jvi_Ka=BtN-_H365+oEBpFrxJv6dU3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-22 01:40 PM, Cong Wang wrote:
> On Mon, Aug 22, 2016 at 5:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>
>>
>> Answered my own question by looking at implementation of kfree();
>> ignores NULL (unlike free())
>
> Seriously?
>
> Here is what C standard says about free():
>

I may be confusing it with fact that the kernel kfree() used to not
check for nullness or perhaps a _lot_ of people used to check for the
null pointer before calling kfree().
[At some point a massive patch must have gone in and cleaned that kind
of code up because i cant find evidence of what i am saying ;->]

cheers,
jamal
