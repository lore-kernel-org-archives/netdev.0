From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 19:04:53 +0200
Message-ID: <20170417170453.GC1895@nanopsycho.orion>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
 <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
 <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170417153133.GA1895@nanopsycho.orion>
 <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35408 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755321AbdDQRE4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:04:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id d79so9942128wmi.2
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 10:04:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 17, 2017 at 06:46:17PM CEST, jhs@mojatatu.com wrote:
>On 17-04-17 11:31 AM, Jiri Pirko wrote:
>> Mon, Apr 17, 2017 at 03:10:59PM CEST, eric.dumazet@gmail.com wrote:
>> > On Mon, 2017-04-17 at 07:01 -0400, Jamal Hadi Salim wrote:
>
>> Agreed.
>> 
>> Plus the argument that attributes are "a big waste" sounds to me really
>> silly. What is couple of bytes?Please do this properly, as it should
>> be done.
>
>Jiri - you wanted to have these uapi discussions, right? ;->
>
>Of course it is trivial to add this as attributes and 32 bits
>for this case is not a big deal because it is done once. I want to talk
>about the pads instead ;-> What do you suggest we do with pads?

I believe we should leave them as they are.


>
>cheers,
>jaaml
>
