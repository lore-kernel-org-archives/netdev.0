From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v10 1/4] net netlink: Add new type NLA_FLAG_BITS
Date: Tue, 13 Jun 2017 06:53:00 -0400
Message-ID: <a7b216d2-921c-c0ac-c036-0466053e807a@mojatatu.com>
References: <4c536950-2be3-cc9c-1f77-066624800d07@mojatatu.com>
 <4441aa62-d00e-82b6-d337-f86cf97e3c6d@mojatatu.com>
 <20170612103432.GA1993@nanopsycho>
 <8e2f151d-3a02-4b1b-755b-23a0a85556b4@mojatatu.com>
 <20170612114345.GB1993@nanopsycho>
 <22f33fa9-1759-57b7-6aea-898f89c9f61f@mojatatu.com>
 <20170612141450.GD1993@nanopsycho>
 <80dd1bc2-80d6-d8fa-6032-d0641ae5d79b@gmail.com>
 <20170612192238.GF1993@nanopsycho>
 <4d150766-dd1e-26f5-43ea-a3c93cdf291b@gmail.com>
 <20170613053258.GA1877@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>, David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34450 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751895AbdFMKxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 06:53:03 -0400
Received: by mail-io0-f194.google.com with SMTP id a96so12591702ioj.1
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 03:53:03 -0700 (PDT)
In-Reply-To: <20170613053258.GA1877@nanopsycho>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-06-13 01:32 AM, Jiri Pirko wrote:
> Mon, Jun 12, 2017 at 09:58:33PM CEST, dsahern@gmail.com wrote:
>> On 6/12/17 1:22 PM, Jiri Pirko wrote:
>>>
>>>> 3. IMO since these are nla prefixes and new NLA type they should be in
>>>> uapi/linux/netlink.h
>>> Including NLA_* type enum? I think it is reasonable.
>>
>> well, maybe not the NLA_BITFIELD. That enum is for policy validation
>> kernel side so not really part of the API.
> 
> Yeah, now I see it. Agreed.
> 

Jiri, you agreed to a name change? ;-> I want to have some of what
David A. ate yesterday.

I agree it is a good idea to have arbitrary size bitmask so we dont
run out of bit space but we need to restrict the max length possible.
I dont agree to using the netlink.h as the best location for this
but lets move on.
Do you or David A. want to take a crack at this?  I am a little tied
up.

cheers,
jamal
