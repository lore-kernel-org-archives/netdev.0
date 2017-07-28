From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Fri, 28 Jul 2017 16:08:40 +0200
Message-ID: <20170728140840.GC1857@nanopsycho>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
 <1a2578ca-35c6-884e-1daf-fcc47e5eb618@gmail.com>
 <7c17a575-53bb-1f25-4a9a-7418f99660f2@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>, davem@davemloft.net,
        netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34744 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbdG1OIn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 10:08:43 -0400
Received: by mail-wr0-f195.google.com with SMTP id o33so19159287wrb.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:08:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <7c17a575-53bb-1f25-4a9a-7418f99660f2@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 28, 2017 at 03:51:41PM CEST, jhs@mojatatu.com wrote:
>On 17-07-25 10:41 AM, David Ahern wrote:
>> On 7/23/17 7:35 PM, Jamal Hadi Salim wrote:
>> > In the most basic form, the user specifies the attribute policy as:
>> > [ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
>> > 
>> > where myvalidflags is the bit mask of the flags the kernel understands.
>> > 
>> > If the user _does not_ provide myvalidflags then the attribute will
>> > also be rejected.
>> 
>> No other netlink attribute has this requirement.
>
>This is the first one where we have to inspect content. We add things
>when we need them - as in this case.
>
>> Users of the attributes
>> are the only ones that know if a value is valid or not (e.g, attribute
>> passing a device index) and those are always checked in line.
>
>It doesnt make sense that every user of the API has to repeat that
>validation code. Same principle as someone specifying that a type is
>u32 and have the nla validation check it. At some point we never had
>the u32 validation code. Then it was factored out because everyone
>repeats the same boilerplate code.
>I see this in the same spirit.

Agreed.
