From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v9 2/3] net sched actions: dump more than
 TCA_ACT_MAX_PRIO actions per batch
Date: Wed, 26 Apr 2017 09:19:54 -0400
Message-ID: <fc75c67b-2413-a9a9-2411-7789eef43203@mojatatu.com>
References: <1493210538-21716-1-git-send-email-jhs@emojatatu.com>
 <1493210538-21716-3-git-send-email-jhs@emojatatu.com>
 <20170426130844.GG1867@nanopsycho.orion>
 <5723f2e0-7738-09f5-23c0-bfe7432d7528@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, simon.horman@netronome.com,
        netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33011 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953066AbdDZNT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 09:19:58 -0400
Received: by mail-it0-f66.google.com with SMTP id z67so452775itb.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 06:19:57 -0700 (PDT)
In-Reply-To: <5723f2e0-7738-09f5-23c0-bfe7432d7528@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-26 09:17 AM, Jamal Hadi Salim wrote:
> On 17-04-26 09:08 AM, Jiri Pirko wrote:
>> Wed, Apr 26, 2017 at 02:42:17PM CEST, jhs@mojatatu.com wrote:
>
>>> +#define VALID_TCA_ROOT_FLAGS TCA_FLAG_LARGE_DUMP_ON
>>> +static inline bool tca_flags_valid(u32 act_flags)
>>> +{
>>> +    u32 invalid_flags_mask  = ~VALID_TCA_ROOT_FLAGS;
>>> +
>>> +    if (act_flags & invalid_flags_mask)
>>> +        return false;
>>> +
>>> +    return true;
>>
>> This dance should either not be here (flag-per-attr) or should be in
>> netlink generic place. This is not TC specific at all.
>>
>
> So where do you think it should be?

It would also be helpful for you to make comments when these things
show up. This change was in version 6. I have had to do this back and
forth a few times.

cheers,
jamal
