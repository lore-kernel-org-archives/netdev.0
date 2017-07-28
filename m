From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Fri, 28 Jul 2017 18:10:20 -0400
Message-ID: <12475aaa-eba1-1c9a-0eec-17c908a627f1@mojatatu.com>
References: <1500860146-26970-4-git-send-email-jhs@emojatatu.com>
 <20170724112750.GC1868@nanopsycho>
 <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
 <20170725113352.GA3186@nanopsycho>
 <355f2140-d8e8-8a4e-1f31-cbbcbfd6821b@mojatatu.com>
 <20170725123728.GC3186@nanopsycho>
 <27472f41-1dd3-66a0-d4fc-6b7290c14b27@mojatatu.com>
 <20170728141234.GD1857@nanopsycho>
 <4e835ac7-0700-726d-7f6c-6e584ff073eb@mojatatu.com>
 <fc91ce4d-b7d1-7e95-7e9a-9265aed68424@mojatatu.com>
 <20170728154547.GG1857@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35903 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752700AbdG1WKX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 18:10:23 -0400
Received: by mail-it0-f49.google.com with SMTP id v205so86973382itf.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 15:10:23 -0700 (PDT)
In-Reply-To: <20170728154547.GG1857@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-28 11:45 AM, Jiri Pirko wrote:
> Fri, Jul 28, 2017 at 05:08:10PM CEST, jhs@mojatatu.com wrote:
>> On 17-07-28 10:52 AM, Jamal Hadi Salim wrote:
>>> On 17-07-28 10:12 AM, Jiri Pirko wrote:


>>         /*disallow invalid selector */
>>         if ((bf->selector & *valid_flags_allowed) > *valid_flags_allowed)
> 
> I don't get the ">"....
> Just (bf->selector & ~*valid_flags_allowed) should be enought, no?
> 

It may be enough - I will try it out tommorow.
I was worried about the selector having more bits than the allowed flags.

cheers,
jamal
