From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v6 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 21 Apr 2017 11:12:00 -0400
Message-ID: <1dea2c80-9c86-353e-6a74-f5b86070df04@mojatatu.com>
References: <1492772132-16559-1-git-send-email-jhs@emojatatu.com>
 <1492772132-16559-3-git-send-email-jhs@emojatatu.com>
 <20170421131220.GC1874@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35671 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162125AbdDURC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:02:29 -0400
Received: by mail-io0-f194.google.com with SMTP id d203so32450767iof.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 10:02:28 -0700 (PDT)
In-Reply-To: <20170421131220.GC1874@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-21 09:12 AM, Jiri Pirko wrote:
> Fri, Apr 21, 2017 at 12:55:31PM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>

>> +#define TCA_FLAG_LARGE_DUMP_ON		(1 << 0)
>
> This is u32 "flags" that could not be extended for other use in future.
> I'm missing the point. Also, you don't check the rest of the bits for 0
> as requested by DaveM.
>
> As far as this is unextendable, please have this as u8 with values 0 and 1
> as I originally suggested.
>
> I don't understand why are we running in circles about this...
>

If i have a 32 bit space of which i am using one bit.
The sender (user space) zeroes the bits except the one they are 
interested in. The kernel checks the bits they are interested in.
Future - we add one more bit and the same philosophy applies.
Older kernels dont see this bit but they dont have the feature
to begin with. So where is the lack of extensibility?

Jiri, there is a balance between extensibility and performance.
It is senseless to use a TLV just so i can set a 0/1(true/false).

cheers,
jamal
