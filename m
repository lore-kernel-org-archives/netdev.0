From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 2/2 v2] net sched actions: add time filter for
 action dumping
Date: Tue, 18 Apr 2017 21:39:40 -0400
Message-ID: <6cf32a44-9d79-fc47-8ec0-d8933db71e49@mojatatu.com>
References: <1492564489-28854-1-git-send-email-jhs@emojatatu.com>
 <1492564489-28854-2-git-send-email-jhs@emojatatu.com>
 <1492565738.10587.155.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@resnulli.us,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35127 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751997AbdDSBjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 21:39:43 -0400
Received: by mail-io0-f182.google.com with SMTP id r16so12391909ioi.2
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 18:39:43 -0700 (PDT)
In-Reply-To: <1492565738.10587.155.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-18 09:35 PM, Eric Dumazet wrote:
> On Tue, 2017-04-18 at 21:14 -0400, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>
>> +	if (tcaa[TCAA_ACT_TIME_FILTER])
>> +		msecs_filter = nla_get_u32(tcaa[TCAA_ACT_TIME_FILTER]);
>
>
> You forgot to add TCAA_ACT_TIME_FILTER in tcaa_policy
>

I will fix that.

> There is no guarantee user passed 32bit data here.
>

Did you mean because we dont have the tcaa_policy or
is it for some other reason?


cheers,
jamal
