From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 3/4] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Sat, 29 Jul 2017 09:19:58 +0200
Message-ID: <20170729071958.GA1858@nanopsycho>
References: <7057a692-7233-4632-4f66-2f57c98322ea@mojatatu.com>
 <20170725113352.GA3186@nanopsycho>
 <355f2140-d8e8-8a4e-1f31-cbbcbfd6821b@mojatatu.com>
 <20170725123728.GC3186@nanopsycho>
 <27472f41-1dd3-66a0-d4fc-6b7290c14b27@mojatatu.com>
 <20170728141234.GD1857@nanopsycho>
 <4e835ac7-0700-726d-7f6c-6e584ff073eb@mojatatu.com>
 <fc91ce4d-b7d1-7e95-7e9a-9265aed68424@mojatatu.com>
 <20170728154547.GG1857@nanopsycho>
 <12475aaa-eba1-1c9a-0eec-17c908a627f1@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38690 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752170AbdG2HUC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 03:20:02 -0400
Received: by mail-wm0-f53.google.com with SMTP id m85so132166282wma.1
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 00:20:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <12475aaa-eba1-1c9a-0eec-17c908a627f1@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Jul 29, 2017 at 12:10:20AM CEST, jhs@mojatatu.com wrote:
>On 17-07-28 11:45 AM, Jiri Pirko wrote:
>> Fri, Jul 28, 2017 at 05:08:10PM CEST, jhs@mojatatu.com wrote:
>> > On 17-07-28 10:52 AM, Jamal Hadi Salim wrote:
>> > > On 17-07-28 10:12 AM, Jiri Pirko wrote:
>
>
>> >         /*disallow invalid selector */
>> >         if ((bf->selector & *valid_flags_allowed) > *valid_flags_allowed)
>> 
>> I don't get the ">"....
>> Just (bf->selector & ~*valid_flags_allowed) should be enought, no?
>> 
>
>It may be enough - I will try it out tommorow.
>I was worried about the selector having more bits than the allowed flags.

That is what the code I wrote above do. And I think that your code does
not (if you don't assume that allowed flags are always starting from the
least significant bit)

>
>cheers,
>jamal
