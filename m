From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v11 1/4] net netlink: Add new type
 NLA_BITFIELD_32
Date: Tue, 25 Jul 2017 07:15:52 -0400
Message-ID: <c492d995-a916-cbed-b545-8d110a6ffb1e@mojatatu.com>
References: <1500860146-26970-1-git-send-email-jhs@emojatatu.com>
 <1500860146-26970-2-git-send-email-jhs@emojatatu.com>
 <20170724111806.GB1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, dsahern@gmail.com,
        eric.dumazet@gmail.com, mrv@mojatatu.com,
        simon.horman@netronome.com, alex.aring@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33008 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbdGYLPy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:15:54 -0400
Received: by mail-it0-f67.google.com with SMTP id t6so9357114itb.0
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:15:54 -0700 (PDT)
In-Reply-To: <20170724111806.GB1868@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-07-24 07:18 AM, Jiri Pirko wrote:
> Mon, Jul 24, 2017 at 03:35:43AM CEST, jhs@mojatatu.com wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>
>> Generic bitflags attribute content sent to the kernel by user.
>> With this type the user can either set or unset a flag in the
>> kernel.
>>
>> The nla_value is a bitmap that defines the values being set
>> The nla_selector is a bitmask that defines which value is legit.
>>
>> A check is made to ensure the rules that a kernel subsystem always
>> conforms to bitflags the kernel already knows about. i.e
>> if the user tries to set a bit flag that is not understood then
>> the _it will be rejected_.
>>
>> In the most basic form, the user specifies the attribute policy as:
>> [ATTR_GOO] = { .type = NLA_BITFIELD_32, .validation_data = &myvalidflags },
>>
>> where myvalidflags is the bit mask of the flags the kernel understands.
>>
>> If the user _does not_ provide myvalidflags then the attribute will
>> also be rejected.
>>
>> Examples:
>> nla_value = 0x0, and nla_selector = 0x1
>> implies we are selecting bit 1 and we want to set its value to 0.
>>
>> nla_value = 0x2, and nla_selector = 0x2
>> implies we are selecting bit 2 and we want to set its value to 1.
> 
> Oh, 2 more things:
> 
> [...]
> 

;-> ok will do that next opportunity (probably at 30K feet).

cheers,
jamal
