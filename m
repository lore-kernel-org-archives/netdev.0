From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/1] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Mon, 17 Apr 2017 12:46:17 -0400
Message-ID: <0bd1e885-cdf3-60fc-783b-a075b777560b@mojatatu.com>
References: <1492346070-6002-1-git-send-email-jhs@emojatatu.com>
 <20170417081936.GA1892@nanopsycho.orion>
 <dfc1485f-7d7e-f52e-f62e-273063a59abc@mojatatu.com>
 <1492434659.10587.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170417153133.GA1895@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Jiri Pirko <jiri@resnulli.us>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:34588 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754786AbdDQQqT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 12:46:19 -0400
Received: by mail-io0-f178.google.com with SMTP id a103so159780108ioj.1
        for <netdev@vger.kernel.org>; Mon, 17 Apr 2017 09:46:19 -0700 (PDT)
In-Reply-To: <20170417153133.GA1895@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-17 11:31 AM, Jiri Pirko wrote:
> Mon, Apr 17, 2017 at 03:10:59PM CEST, eric.dumazet@gmail.com wrote:
>> On Mon, 2017-04-17 at 07:01 -0400, Jamal Hadi Salim wrote:

> Agreed.
>
> Plus the argument that attributes are "a big waste" sounds to me really
> silly. What is couple of bytes?Please do this properly, as it should
> be done.

Jiri - you wanted to have these uapi discussions, right? ;->

Of course it is trivial to add this as attributes and 32 bits
for this case is not a big deal because it is done once. I want to talk
about the pads instead ;-> What do you suggest we do with pads?

cheers,
jaaml
