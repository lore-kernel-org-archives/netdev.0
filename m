From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v9 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 15:48:48 +0200
Message-ID: <20170426134848.GH1867@nanopsycho.orion>
References: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
 <1493210538-21716-3-git-send-email-jhs@emojatatu.com>
 <20170426130844.GG1867@nanopsycho.orion>
 <5723f2e0-7738-09f5-23c0-bfe7432d7528@mojatatu.com>
 <fc75c67b-2413-a9a9-2411-7789eef43203@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35997 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S3000662AbdDZNsv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:48:51 -0400
Received: by mail-wr0-f196.google.com with SMTP id v42so103548wrc.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:48:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <fc75c67b-2413-a9a9-2411-7789eef43203@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 26, 2017 at 03:19:54PM CEST, jhs@mojatatu.com wrote:
>On 17-04-26 09:17 AM, Jamal Hadi Salim wrote:
>> On 17-04-26 09:08 AM, Jiri Pirko wrote:
>> > Wed, Apr 26, 2017 at 02:42:17PM CEST, jhs@mojatatu.com wrote:
>> 
>> > > +#define VALID_TCA_ROOT_FLAGS TCA_FLAG_LARGE_DUMP_ON
>> > > +static inline bool tca_flags_valid(u32 act_flags)
>> > > +{
>> > > +    u32 invalid_flags_mask  = ~VALID_TCA_ROOT_FLAGS;
>> > > +
>> > > +    if (act_flags & invalid_flags_mask)
>> > > +        return false;
>> > > +
>> > > +    return true;
>> > 
>> > This dance should either not be here (flag-per-attr) or should be in
>> > netlink generic place. This is not TC specific at all.
>> > 
>> 
>> So where do you think it should be?
>
>It would also be helpful for you to make comments when these things
>show up. This change was in version 6. I have had to do this back and
>forth a few times.

I still think that this whole thing is wrong, so that is why. Version 6
it is just because you are pushing versions too fast without actually
reaching consensus (I know why you are doing this, you really want to
push this through. I think it is not good).
