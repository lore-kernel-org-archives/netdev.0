From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 13:51:32 -0400
Message-ID: <851ssqq5wb.fsf@mojatatu.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
        <20170417081936.GA1892@nanopsycho.orion>
        <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
        <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170417153133.GA1895@nanopsycho.orion>
        <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
        <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
        davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33454 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754658AbdDQRvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:51:35 -0400
Received: by mail-io0-f194.google.com with SMTP id k87so28012377ioi.0
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 10:51:35 -0700 (PDT)
In-Reply-To: <1492448905.10587.109.camel@edumazet-glaptop3.roam.corp.google.com>
        (Eric Dumazet's message of "Mon, 17 Apr 2017 10:08:25 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Mon, 2017-04-17 at 12:46 -0400, Jamal Hadi Salim wrote:
>
>> Of course it is trivial to add this as attributes and 32 bits
>> for this case is not a big deal because it is done once. I want to talk
>> about the pads instead ;-> What do you suggest we do with pads?
>
> We do nothing with pads. Just leave them.
>
> Or, you need something to make sure to not break old user applications.
>
> Something like a version.

Would be a new NLM_F_* modifier for GET request an option for large
dumps implementation? Looks like there are extract bits and Johannes'
patches for extended ACK do not use it.
