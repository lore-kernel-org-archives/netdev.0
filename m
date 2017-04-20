From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4 1/2] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Thu, 20 Apr 2017 09:27:00 -0400
Message-ID: <48ec5026-38bf-ebfd-98e5-78c8cb1d24f5@mojatatu.com>
References: <1492603050-9318-1-git-send-email-jhs@emojatatu.com>
 <20170419123645.GB3357@nanopsycho.orion>
 <705a4d67-4a81-113f-e22a-0ca0bb6cf1eb@mojatatu.com>
 <20170419131323.GE3357@nanopsycho.orion>
 <e2a1e201-4830-e600-e668-91f83bcc9b32@mojatatu.com>
 <20170419155400.GH3357@nanopsycho.orion>
 <56488055-1f4b-ee10-2357-5ce80f1fbc50@mojatatu.com>
 <20170419161736.GJ3357@nanopsycho.orion>
 <f0e84f44-ba3a-7eb4-8b22-9764048d9406@mojatatu.com>
 <1492690694.22296.32.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33712 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943562AbdDTN1I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 09:27:08 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so16328449ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 06:27:07 -0700 (PDT)
In-Reply-To: <1492690694.22296.32.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-20 08:18 AM, Eric Dumazet wrote:
> On Thu, 2017-04-20 at 06:42 -0400, Jamal Hadi Salim wrote:
>
>>
>> They are not the same issue Jiri. We have used bitmasks fine on netlink
>> message for a millenia. Nobody sets garbage on a bitmask they are not
>> supposed to touch. The struct padding thing is a shame the way it
>> turned out - now netlink can no longer have a claim to be a (good)
>> wire protocol.
>
> Except that users wrote programs, and these programs work today.
>
> By changing the kernel and recognizing new flags in existing padding,
> you might break the programs.
>
> This is not acceptable. Period.
>
> Had we checked the padding being 0 in old kernels, this change would
> have been possible today.
>
> But because old kernels did not care of the padding contents, then there
> is no way new kernel can suddenly trust them at all.
>
> Please Jamal, you have to forget this nonsense.

That is fine. We can rule out netlink ever being able to work
across machines. That was the dream in the past. Lets close that
discussion.

The issue Jiri is bringing up is unrelated. He is talking about
a bitmap and conflating it with a data structure. They are not
the same issue.

cheers,
jamal

>
